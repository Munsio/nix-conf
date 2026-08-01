# vortex: edge cases and gotchas

A grab-bag reference for the non-obvious stuff discovered while building and
running `vortex`. See `docs/vortex-bare-metal-migration.md` for the full
story of the Proxmox VM → bare-metal migration; this doc is the condensed,
"what to watch out for" version plus everything since.

## Bare-metal install (`nixos-anywhere` + kexec)

Full detail in `docs/vortex-bare-metal-migration.md`. Short version:

- **Proxmox `authorized_keys` is a symlink into `pmxcfs`**
  (`/etc/pve/priv/authorized_keys`), which refuses writes once a node loses
  cluster quorum. Broke `nixos-anywhere`'s initial key copy after removing
  pve-main from its cluster. Fix: replace the symlink with a plain file
  (safe since the disk was about to be wiped).
- **The default kexec installer's `restore-network` service actively
  overwrites your network config**, not just fails passively. It tries to
  auto-replicate the *previous* system's `ip addr`/`ip route` state, and
  can't parse a bridge+VLAN setup (`vmbr0.30`) — it clobbered a correct
  static VLAN config that NixOS activation had already written, because it
  runs later in boot (`before = network-pre.target`). Fix: build a custom
  kexec image via `nixosModules.kexec-installer` (from
  `github:nix-community/nixos-images`) with the right static VLAN baked in
  **and** `systemd.services.restore-network.enable = lib.mkForce false`,
  passed to `nixos-anywhere --kexec <tarball>`.
- A failed kexec attempt leaves the machine running the broken installer in
  RAM with no network — only recovery is a physical reboot. The disk isn't
  touched until the actual install step, so it boots back into whatever was
  there before every time.

## Openbox/X11 + Sunshine autostart chain

- `services.xserver.displayManager.startx.generateScript = true` is load-bearing,
  not cosmetic. Without it, NixOS never writes `/etc/X11/xinit/xinitrc`, so
  `startx` silently falls back to xinit's bare default (just `xterm`, no
  window manager — looks like "a white box" from the outside). The
  generated xinitrc also starts `nixos-fake-graphical-session.target`,
  which Sunshine's `wantedBy = ["graphical-session.target"]` user service
  is actually waiting on — without this, Sunshine silently never autostarts
  even though Openbox itself launches fine.
- `services.greetd.settings.initial_session` (not the default `tuigreet`
  session) is greetd's real autologin mechanism — skips the greeter,
  launches the given command directly as `martin` on boot.

## Virtual DP-1 display + EDID (`hosts/vortex/default.nix`, `hosts/vortex/home.nix`)

vortex has no monitor plugged into its second output, but Sunshine needs a
capture target at a resolution/refresh the real monitor's cable can't
carry. The chain to make that work:

- **`systemd.services.force-dp1-connector`** (`hosts/vortex/default.nix`,
  ~line 128): a oneshot unit that writes `hosts/vortex/dp1-edid.bin`
  (a real EDID cloned from the working HDMI-2 monitor) into
  `/sys/kernel/debug/dri/0000:0c:00.0/DP-1/edid_override`, then echoes `on`
  to `.../DP-1/force`. This makes amdgpu/Xorg treat DP-1 as a genuine
  connected output.
  - **Why a real EDID, not just forcing the connector**: an EDID-less
    forced connector gets periodically re-probed by the kernel's connector
    polling and fails every time ("No EDID found on connector: DP-1"),
    which was observed correlating with real display-pipeline hardware
    stalls (REG_WAIT timeouts in dcn401/mpc) and, in turn, Sunshine capture
    freezes. A real (if borrowed) EDID makes those periodic probes succeed
    cleanly instead.
- **The Openbox autostart script** (`hosts/vortex/home.nix`, `vortex-display`
  home module, ~line 33) sets the actual 3440x1440@100 mode via `xrandr` —
  the EDID above doesn't carry this mode, so it's forced separately once X
  starts. HDMI-2 keeps its native/preferred mode (it's only for occasional
  emergency local access — normally off — so there's no reason to touch it).
- **The custom modeline must be CVT-RB v2 (reduced blanking), not plain
  CVT/GTF — this was the actual cause of "thrown back to the wrong
  resolution" recurring (2026-07-24).** Plain CVT/GTF for 3440x1440@100
  computes a 728MHz pixel clock (verified: both `gtf 3440 1440 100` and
  plain `cvt` reproduce this exactly). That's too demanding for the CRTC to
  reliably commit — symptom was DP-1 silently stuck at its EDID-preferred
  1920x1080 (mode present in `xrandr`'s list, just never made active),
  `xrandr` failing outright with "Configure crtc 0 failed" on manual
  retry, and Xorg logging `(EE) modeset(0): failed to set mode: No such
  file or directory` with no corresponding dmesg detail. This happened even
  right after a fresh reboot, so it was never reliably working, not just
  "broken by fiddling." A proper CVT-RB v2 timing for the same
  resolution/refresh needs only **531.52MHz** — computed with
  `kevinlekiller/cvt_modeline_calculator_12` (`cvt12.c`, since nixpkgs'
  `xorg.xorgserver` only ships `gtf`, not `cvt`, at all) via
  `./cvt12 3440 1440 100 -b`. This has been reliable in testing where the
  plain-CVT mode wasn't, on both DP-1 and (experimentally, not kept)
  directly on the real HDMI-2 monitor too — meaning the original
  "monitor's cable can't carry it" assumption may have partly been an
  artifact of using an unnecessarily oversized timing, not a hard limit.
  Current modeline: `--newmode "3440x1440_100.00_rb2" 531.52 3440 3448
  3480 3520 1440 1496 1504 1510 +hsync -vsync`.
- Also worth knowing: the `optc401_disable_crtc` REG_WAIT timeout (see
  above) fires on **every single boot** (confirmed via `dmesg`, twice, on a
  completely fresh reboot on 2026-07-24) — it's not intermittent. It
  doesn't seem to prevent DP-1 from working once the mode-clock issue above
  is fixed, but if display weirdness ever recurs, check this first before
  assuming something new broke.
- **Sunshine's `output_name = "1"` is not the index Sunshine's own logs
  suggest.** Sunshine's KMS backend indexes by connector *activation
  order*, not the "Detected display: ... (id: N)" log line (which lists
  DP-1 as `0`). HDMI-2 is already active before `force-dp1-connector` runs,
  so it claims index `0`, making DP-1 index `1`. Confirmed via
  `journalctl --user -u sunshine | grep "connector ID"`.

## go-hass-agent (`features/go-hass-agent.nix`)

- **It exits `0` even when it fails to start.** E.g. at boot, if HA is
  unreachable because DNS isn't up yet, it logs an `ERROR` and then exits
  cleanly (status 0). This means `Restart=on-failure` in the systemd unit
  **never triggers** — systemd correctly sees a "successful" exit. Fixed by
  using `Restart=always` instead (ignores exit code) plus
  `Wants=network-online.target` (not just `After=`, so the unit actually
  pulls in network readiness rather than merely ordering after it).
- **No compositor-specific portal exists for Openbox** (that's a Wayland-only
  concept, e.g. `xdg-desktop-portal-wlr`). The generic, WM-agnostic
  `xdg-desktop-portal-gtk` backend works fine under plain X11 and clears
  the "no portal present" / "no desktop portal in context" warnings.
  Enabled via `xdg.portal.enable = true;` in `features/openbox.nix`.
- **It always shows up as two separate devices in Home Assistant** — the
  Mobile App (webhook) integration for sensors, and a second device under
  the MQTT integration for controls (buttons) and some MQTT-only sensors.
  This is a hard architecture limitation (confirmed via upstream FAQ: "Go
  Hass Agent cannot run in an MQTT-only credentials... not MQTT only"), not
  something fixable in config — the webhook registration is mandatory
  infrastructure, not optional.
- **MQTT power controls (Power Off/Reboot) require MQTT to be separately
  configured** (`go-hass-agent config --mqtt-enabled --mqtt-server=...
  --mqtt-user=... --mqtt-password=...`) even after the base webhook
  registration is done — the two are independent. Needs
  `systemd-logind`+D-Bus for the actual power actions (present here).
- **`sensor.vortex_power_state`** (enum: Powered On / Powered Off /
  Suspended, D-Bus-sourced) appears to be published with an MQTT
  Last-Will payload of "Powered Off" — it flips near-instantly when the
  agent's MQTT connection drops (confirmed by manually stopping the
  service and watching it in HA). This is a much more reliable "is vortex
  actually running" signal than pinging the host, and is what the
  `switch.vortex` Template Switch helper in HA is built on.
- Assorted harmless warnings seen in the logs, none of which trace back to
  anything in this repo's config: missing `pw-dump`/`chronyc` binaries
  (pipewire/chrony sensors just don't populate), no D-Bus policy for
  `abrt`/`UPower` (their workers no-op), and an intermittent "Send sensor
  registration failed" with empty name/state/type (looks like an internal
  go-hass-agent bug in one of the workers, not a config issue).

## MQTT / EMQX / Home Assistant networking

- **`ha.treml.group` and `homeassistant.treml.group` are different hosts.**
  `ha.treml.group` resolves to the OPNsense router (`10.10.40.1`) — an
  unrelated DNS record on the same domain. The actual Home Assistant box is
  `homeassistant.treml.group` (`10.10.150.10`). Easy to lose an hour to
  this if you assume the obvious hostname.
- EMQX (running directly on the HA host, not the Mosquitto add-on) requires
  authentication — connecting without a username/password gets rejected
  with MQTT5 reason code `134`/`0x86` ("Bad Username or Password"), even if
  you don't think a password is set.

## Wake-on-LAN

- vortex has **two physical ethernet NICs**: `enp4s0` (Aquantia 10G,
  `atlantic` driver — the one actually cabled up and used for LAN/VLAN100)
  and `enp6s0` (Intel onboard, `igb` driver — **no cable connected**).
  Both report WOL hardware support via `ethtool` ("Supports Wake-on:
  pg"/"pumbg" respectively), but only `enp4s0` is usable since it's the
  only one physically connected. `igb` is generally the more
  battle-tested WOL chip, but doesn't matter here since it's unplugged.
- MAC for WOL: `fc:34:97:2e:c9:8a` (enp4s0). Enabled via
  `"802-3-ethernet".wake-on-lan = "magic";` on the `lan` NetworkManager
  profile in `hosts/vortex/default.nix`.
- BIOS-level WOL was already confirmed enabled (this exact hardware did
  WOL successfully when it still ran Proxmox).
- **NixOS's `networking.networkmanager.ensureProfiles` doesn't reliably
  push property changes to the driver for an already-active connection.**
  The generated keyfile has no stable `uuid`, so `nmcli connection reload`
  (which is what the declarative-profile activation script runs) doesn't
  merge cleanly into a connection that's already up — the file on disk was
  correct, `nmcli connection show lan` still reported the old value. Had
  to manually run `nmcli connection modify lan 802-3-ethernet.wake-on-lan
  magic` then `nmcli connection up lan` to force it, after which `ethtool`
  confirmed the change. A fresh boot (profile read before the connection
  is ever activated) should apply cleanly without this workaround, but
  that hasn't been verified across an actual reboot yet — worth
  double-checking after the next one.

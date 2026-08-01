# vortex: from Proxmox VM (pve-main) to bare-metal NixOS

## Background

`vortex` was originally a Proxmox VM (VMID 100) running on `pve-main`, set up as a
gaming/streaming box: Hyprland desktop, Sunshine for Moonlight streaming, an AMD
Radeon RX 9070 XT (Navi 48 / RDNA4) passed through via VFIO.

That passthrough setup turned out to be fundamentally broken for this GPU. This
document covers why, and the full process of turning `pve-main` itself into
`vortex` — a dedicated bare-metal NixOS gaming host — instead.

## Why VFIO passthrough was abandoned

Symptom: the entire physical host would hard-hang (unrecoverable without a
physical power cycle) shortly after starting the vortex VM — sometimes within a
second of the VM starting, sometimes ~26 seconds in.

Root cause investigation (via `journalctl -b -1`/`-b -2` on pve-main):

- The Proxmox host-side `pre-start` hookscript (`rx9070_reset.sh`) — which wakes
  the GPU via the real `amdgpu` driver, does a BAR2 resize, then rebinds it to
  `vfio-pci` — completed successfully every time. Not the failure point.
- The hang happened *after* successful VM start, once the guest's own `amdgpu`
  driver began touching the card for real.
- Upstream [`vendor-reset`](https://github.com/gnif/vendor-reset) (the standard
  kernel-level fix for this class of bug) has **no support for Navi 48 / RX
  9070** at all.
- Community reports (Proxmox forums, r/VFIO, as of mid-2026) confirm this is a
  known, unresolved, hardware/firmware-level issue for this GPU generation on
  Linux guests specifically. AMD has told at least one user in writing that PCI
  passthrough isn't officially supported on consumer RDNA3/4 cards.

Conclusion: no reliable software fix exists yet. Since the whole point of
`vortex` is Sunshine streaming with real GPU encode, running it on bare metal
with native `amdgpu` access sidesteps the passthrough reset bug entirely — no
VFIO, no dual-driver handoff, no reset dance required.

## Desktop stack change: Hyprland/Wayland → Openbox/X11

Independent of the passthrough decision: Sunshine's Wayland (wlroots
screencopy) capture path is still immature for headless capture (no physical
monitor attached). Its X11 + KMS-grab capture path is mature and is what most
self-hosted Sunshine/Moonlight boxes actually use. So vortex runs:

- `services.xserver.windowManager.openbox.enable = true`
- `services.xserver.displayManager.startx.enable = true` **with
  `generateScript = true`** — this is the option that actually matters. Without
  it, NixOS never writes `/etc/X11/xinit/xinitrc`, so `startx` silently falls
  back to xinit's bare default (a lone `xterm`, no window manager at all — this
  is why it looked like "a white box in text mode instead of a GUI"). With
  `generateScript = true`, the generated xinitrc also runs
  `systemctl --user start nixos-fake-graphical-session.target`, which
  `BindsTo=graphical-session.target` — the thing Sunshine's systemd user
  service (`wantedBy = ["graphical-session.target"]`) is actually waiting on.
  Without this, Sunshine would silently never autostart even though Openbox
  itself launched fine.
- `services.greetd.settings.initial_session` (not the default `tuigreet`
  session) — this key is greetd's actual autologin mechanism: it skips the
  greeter and launches the given command directly as `martin` on boot.

Game launchers: Steam + Heroic (system-level) + Lutris (as a **home-manager**
`programs.lutris.enable = true`, not a NixOS module — it's a per-user tool, not
a system service).

## Disk layout (`hosts/vortex/disko.nix`)

Two physical disks in the machine:

- **500GB Samsung 970 EVO** (true NVMe) → OS disk
- **1TB Samsung 860 EVO M.2** (SATA, not NVMe — shows as `/dev/sda`, `ata-`
  prefix, despite being an M.2 form factor) → data disk

Layout decided on:

- OS disk: 1G vfat ESP (`/boot`) + one `btrfs` partition split into subvolumes:
  `@` → `/`, `@home` → `/home`, `@nix` → `/nix`, `@log` → `/var/log`. Btrfs was
  chosen specifically for root snapshot/rollback flexibility, not for
  space-saving.
- Data disk: single `ext4` partition → `/data`.
- **No compression** (`compress=zstd` was considered, then explicitly dropped).
  Reasoning: this box's only job is Sunshine streaming, which is CPU/latency
  sensitive. Game data itself lives on `/data` (already ext4, uncompressed) and
  isn't touched during a stream anyway, so compression would only add a
  background CPU cost with no benefit for the one workload that matters —
  `noatime` was kept since that's pure upside (no CPU cost, just skips
  metadata writes on reads).
- `@home` was deliberately kept on the OS disk (not moved to the data disk)
  even though Steam/Lutris/Wine default data lives under `$HOME` — a tradeoff
  for keeping the btrfs subvolume layout simple. Steam's library folder and
  Lutris's install path need to be manually pointed at `/data` once the system
  is up; it doesn't happen automatically.
- Device paths use stable `/dev/disk/by-id/...`, not `/dev/nvme0n1`-style
  paths (those aren't guaranteed stable across boots).

## Networking: VLAN 100 tagging

The switch port `enp4s0` connects to is a VLAN-aware trunk with no native/
untagged VLAN — Proxmox's bridge (`vmbr0`, `bridge-vlan-aware yes`) handled
802.1Q tagging transparently for VMs (VM 100 had `tag=100` on its virtual
NIC). On bare metal there's no bridge to do that translation, so the OS itself
must tag traffic:

```nix
networking.networkmanager.ensureProfiles.profiles = {
  lan = {
    connection = { id = "lan"; type = "ethernet"; interface-name = "enp4s0"; autoconnect = true; };
    ipv4.method = "disabled";
    ipv6.method = "disabled";
  };
  vlan100 = {
    connection = { id = "vlan100"; type = "vlan"; autoconnect = true; };
    vlan = { id = 100; parent = "enp4s0"; };
    ipv4.method = "auto";
    ipv6.method = "auto";
  };
};
```

`enp4s0` is systemd's predictable PCI-path-based interface name
(`0000:04:00.0`) — a hardware property, not a Proxmox/Debian artifact, so it's
expected to be identical under NixOS on the same board.

## Proxmox cluster removal

`pve-main` was part of a 4-node cluster (`HomeLab`: pve-main, pve-ssd,
pve-asus1, pve-asus2). Before wiping it:

1. Stopped/confirmed VM 100 and VM 105 (Windoof-2) not needed.
2. Ran `pvecm delnode pve-main` **from a different node** (pve-ssd) — never
   run this from the node being removed. Quorum recalculated cleanly from 4 to
   3 nodes.
3. Skipped the usual "separate node without reinstalling" local cleanup
   (`pmxcfs -l`, clearing `/etc/corosync/*`) since the disk was about to be
   wiped anyway — this later caused a real, if minor, snag (see below).

Pre-existing, unrelated finding: cluster's `Expected votes` was 5 with only 4
real nodes even before this — a leftover phantom vote from some earlier
node removal that was never fully cleaned up. Not blocking, but noted.

## The `nixos-anywhere` install: two real snags

Deploying via:

```
nix run github:nix-community/nixos-anywhere -- --flake .#vortex root@pve-main.treml.group
```

### Snag 1: `authorized_keys` symlinked into pmxcfs

`nixos-anywhere`'s first step (`ssh-copy-id`-ing its own temporary install key)
failed in an infinite retry loop with `cat: write error: Permission denied`.

Cause: `/root/.ssh/authorized_keys` on Proxmox is a symlink to
`/etc/pve/priv/authorized_keys` — Proxmox's clustered config filesystem
(`pmxcfs`), which refuses writes once a node loses cluster quorum (a
split-brain safety measure). Since pve-main had just been cleanly removed
from the cluster, this symlink was now unwritable.

Fix (safe since the disk was about to be wiped regardless): backed up the key
list, deleted the symlink, replaced it with a plain writable file containing
the same keys.

### Snag 2: kexec installer's `restore-network` clobbers custom VLAN config

`nixos-anywhere` downloads a generic kexec installer image by default. That
image tries to auto-detect and replicate the *previous* system's network
config via an active `restore-network` systemd service
(`nix-community/nixos-images`, `nix/kexec-installer/module.nix`) that runs at
boot and writes directly into `/etc/systemd/network/` based on a live
snapshot of the old system's `ip addr`/`ip route` output.

Proxmox's actual address lived on `vmbr0.30` — a bridge + VLAN sub-interface,
not a plain interface — which this auto-detection can't correctly parse. Two
different failures resulted from this, in order:

1. **Default kexec image**: fell back to plain untagged DHCP on `enp4s0`
   entirely. The trunk port doesn't answer untagged traffic at all → the
   installer was completely unreachable (dozens of `Connection timed out`
   retries, no meaningful timeout point — this is what "not working" looked
   like from the outside).
2. **First custom kexec image** (static VLAN 30 config baked in, matching
   pve-main's real address): still didn't work. Console access confirmed why —
   no `vlan30` interface existed at all after kexec. The `restore-network`
   service runs late enough in boot (`before = ["network-pre.target"];
   wantedBy = ["multi-user.target"]`) to overwrite whatever static
   `/etc/systemd/network/*` files NixOS activation had already put there.

Fix: built a fully custom kexec image (see
`nixosModules.kexec-installer` from `github:nix-community/nixos-images`) with:

- An explicit static VLAN 30 interface matching pve-main's real config
  (`enp4s0` tagged VLAN 30, static `10.10.30.14/24`, gateway `10.10.30.1`) —
  this is *only* for the installer to be reachable during install; the final
  `vortex` config's own VLAN 100 networking is unrelated and unaffected.
- `systemd.services.restore-network.enable = lib.mkForce false;` — disabling
  the auto-detection service entirely, since it wasn't just failing passively,
  it was actively overriding a correct static config with a broken one.

Built via:

```nix
let
  nixos-images = builtins.getFlake "github:nix-community/nixos-images";
  nixpkgs = nixos-images.inputs.nixos-stable;
in
  (nixpkgs.legacyPackages.x86_64-linux.nixos [
    nixos-images.nixosModules.kexec-installer
    nixos-images.nixosModules.noninteractive
    ({lib, ...}: {
      networking.vlans.vlan30 = { id = 30; interface = "enp4s0"; };
      networking.interfaces.vlan30.ipv4.addresses = [{ address = "10.10.30.14"; prefixLength = 24; }];
      networking.defaultGateway = { address = "10.10.30.1"; interface = "vlan30"; };
      networking.nameservers = ["1.1.1.1" "8.8.8.8"];
      systemd.services.restore-network.enable = lib.mkForce false;
    })
  ]).config.system.build.kexecInstallerTarball
```

...then passed to nixos-anywhere via `--kexec <path-to-tarball>` instead of
letting it fetch the default image.

Each time an attempt failed mid-kexec, the machine was left running the
broken installer in RAM with no network — the only recovery was a physical
reboot (disk was never touched at that point, so it booted straight back into
the original Proxmox install every time).

## Result

`vortex` now runs directly on the hardware formerly known as `pve-main`:
NixOS + Openbox + Sunshine (native `amdgpu`, no VFIO) + Steam/Heroic/Lutris,
autologin via greetd, VLAN 100 tagged networking, btrfs root + ext4 `/data`.

{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.vortex = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.common
      self.nixosModules.nixos
      self.nixosModules.unstableOverlay
      self.nixosModules.systemd-boot
      self.nixosModules.openssh
      self.nixosModules.amdgpu
      self.nixosModules.audio
      self.nixosModules.sunshine
      self.nixosModules.go-hass-agent
      self.nixosModules.steam
      self.nixosModules.heroic
      self.nixosModules.greetd
      self.nixosModules.openbox
      self.nixosModules.martin-user
      self.nixosModules.vortex-home-manager
      self.nixosModules.vortex-disko
      self.nixosModules.sudo
      inputs.disko.nixosModules.disko
    ];

    sudo.passwordlessSwitch = {
      enable = true;
      users = ["martin"];
    };

    networking = {
      hostName = "vortex";
      networkmanager.enable = true;
      networkmanager.ensureProfiles.profiles = {
        lan = {
          connection = {
            id = "lan";
            type = "ethernet";
            interface-name = "enp4s0";
            autoconnect = true;
          };
          # Magic-packet WOL, so an HA switch/automation can power vortex back
          # on. Also needs the corresponding BIOS "Wake on LAN"/"Power On By
          # PCI-E" option enabled — this only covers the OS/driver side.
          "802-3-ethernet".wake-on-lan = "magic";
          ipv4.method = "disabled";
          ipv6.method = "disabled";
        };

        vlan100 = {
          connection = {
            id = "vlan100";
            type = "vlan";
            autoconnect = true;
          };
          vlan = {
            id = 100;
            parent = "enp4s0";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };

    services = {
      greetd.settings.initial_session = {
        command = "startx";
        user = "martin";
      };

      openssh.openFirewall = lib.mkForce true;

      fstrim.enable = true;

      sunshine.settings = {
        csrf_allowed_origins = "https://vortex.treml.group";
        do_cmd = "";
        # vaapi over the newer, less mature vulkan encoder (Sunshine#4944, #5020).
        # Washed-out colors were the client: moonlight-qt <6.2.0 mishandles 8-bit full range (moonlight-qt#1667).
        encoder = "vaapi";
        # KMS display index targeting the forced virtual DP-1 output. This is
        # NOT the index shown in sunshine's "Detected display: ... (id: N)"
        # log (that lists DP-1 as 0) — Sunshine's KMS backend indexes by
        # connector *activation order*, not that log line, so the right value
        # depends on whether HDMI-2 (the real monitor) is connected at boot.
        #
        # HDMI-2 is normally unplugged/off (it's only for occasional emergency
        # local access), so in the common case DP-1 is the *only* active
        # connector and claims index 0. This broke on 2026-07-26 when the
        # config still had "1" left over from an earlier boot where HDMI-2
        # happened to be connected first, making Sunshine unable to find any
        # display at all ("Couldn't find monitor [1]") and fail every encoder.
        #
        # If HDMI-2 is ever intentionally connected for local troubleshooting,
        # it will likely claim index 0 again and this may need to flip back to
        # "1" — confirm via `journalctl --user -u sunshine | grep "Detected
        # display"` order. Upstream Sunshine gained direct connector-name
        # support for this option (output_name = "DP-1", no more index
        # guessing) in LizardByte/Sunshine#5423, merged 2026-07-22 — revisit
        # once a nixpkgs release packaging that lands, to drop this ordering
        # dependency entirely.
        output_name = "0";
      };
    };

    # logind requires interactive polkit auth for reboot/poweroff by default,
    # which has nowhere to go on this headless box (no polkit auth agent
    # running). Grant it unconditionally for wheel so the Openbox power
    # menu items actually work.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.login1.reboot" ||
             action.id == "org.freedesktop.login1.power-off") &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';

    environment.systemPackages = with pkgs; [
      mangohud
      pcmanfm
    ];

    # /data is a fresh ext4 filesystem — disko doesn't set any particular
    # ownership on mount, so it defaults to root:root 0755 (unwritable by
    # martin). This is the game library disk, so martin needs write access.
    systemd.tmpfiles.rules = ["d /data 0755 martin users -"];

    # Virtual Sunshine display on the empty DP-1 connector: forced on from boot
    # with a generated EDID whose only mode is 3440x1440@100 (CVT-RB v2; plain
    # CVT's 728MHz clock failed to commit on the CRTC).
    hardware.display = {
      edid.modelines."vortex-uw100" = "531.52 3440 3448 3480 3520 1440 1496 1504 1510 +hsync -vsync ratio=16:9 vfreq=100";
      outputs."DP-1" = {
        edid = "vortex-uw100.bin";
        mode = "e";
      };
    };

    nixpkgs.overlays = [
      (_: prev: {
        # Backport the kernel's 2019 edid.S sync-bit packing fix (vsync offset >15 got mangled)
        # and drop the standard timing slot, which can't represent widths over 2288px.
        edid-generator = prev.edid-generator.overrideAttrs (old: {
          postPatch =
            old.postPatch
            + ''
              substituteInPlace modeline2edid \
                --replace-fail '"(63+$((vsyncstart - vdisp)))"' '"$((vsyncstart - vdisp))"' \
                --replace-fail '"(63+$((vsyncend - vsyncstart)))"' '"$((vsyncend - vsyncstart))"'
              substituteInPlace edid.S \
                --replace-fail '(((v1&0x03)>>2)+((v2&0x03)>>4)+((v3&0x03)>>6)+((v4&0x03)>>8))' \
                  '((((v1>>8)&0x03)<<6)+(((v2>>8)&0x03)<<4)+(((v3>>4)&0x03)<<2)+((v4>>4)&0x03))' \
                --replace-fail '((YOFFSET-63)<<4)+(YPULSE-63)' '((YOFFSET&0x0f)<<4)+(YPULSE&0x0f)' \
                --replace-fail '.byte	(XPIX/8)-31' '.byte	0x01' \
                --replace-fail '.byte	(XY_RATIO<<6)+VFREQ-60' '.byte	0x01'
            '';
        });
      })
    ];
  };

  flake.nixosConfigurations.vortex = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      self.nixosModules.vortex
      ./hardware-configuration.nix
    ];
  };
}

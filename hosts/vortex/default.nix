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

    networking.hostName = "vortex";
    networking.networkmanager.enable = true;
    networking.networkmanager.ensureProfiles.profiles = {
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

    services.greetd.settings.initial_session = {
      command = "startx";
      user = "martin";
    };

    services.openssh.openFirewall = lib.mkForce true;

    services.fstrim.enable = true;

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

    services.sunshine.settings = {
      csrf_allowed_origins = "https://vortex.treml.group";
      do_cmd = "";
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

    environment.systemPackages = with pkgs; [
      mangohud
      pcmanfm
    ];

    # /data is a fresh ext4 filesystem — disko doesn't set any particular
    # ownership on mount, so it defaults to root:root 0755 (unwritable by
    # martin). This is the game library disk, so martin needs write access.
    systemd.tmpfiles.rules = ["d /data 0755 martin users -"];

    # Force the otherwise-unused DP-1 connector to report as connected, so
    # amdgpu/Xorg exposes it as a genuine second RandR output alongside the
    # real physical HDMI-2 monitor. Nothing is actually plugged into DP-1, so
    # there's no real link/bandwidth negotiation to fail — this is purely a
    # virtual target for Sunshine to capture at a resolution/refresh rate the
    # real monitor's cable can't carry, while HDMI-2 keeps working natively
    # for local troubleshooting.
    #
    # A forced-but-EDID-less connector gets periodically re-probed by the
    # kernel's connector polling and fails every time ("No EDID found on
    # connector: DP-1"), which was observed correlating with real display-
    # pipeline hardware stalls (REG_WAIT timeouts in dcn401/mpc) and, in
    # turn, Sunshine capture freezes. Feeding it a real EDID (cloned as-is
    # from the working HDMI-2 monitor — guaranteed valid, no hand-crafting)
    # makes those periodic probes succeed cleanly instead. The actual
    # 3440x1440@100 mode is still forced separately via xrandr in the
    # Openbox autostart script regardless of what this EDID advertises.
    systemd.services.force-dp1-connector = {
      description = "Force DP-1 connector active for virtual Sunshine display";
      wantedBy = ["multi-user.target"];
      before = ["greetd.service"];
      after = ["sys-kernel-debug.mount"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writeShellScript "force-dp1" ''
          cat ${./dp1-edid.bin} > /sys/kernel/debug/dri/0000:0c:00.0/DP-1/edid_override
          echo on > /sys/kernel/debug/dri/0000:0c:00.0/DP-1/force
        ''}";
      };
    };
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

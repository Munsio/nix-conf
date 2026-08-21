{...}: {
  flake.nixosModules.yubikey = {pkgs, ...}: {
    services = {
      pcscd.enable = true;
      yubikey-agent.enable = true;
      udev.packages = [pkgs.yubikey-personalization];
    };

    programs = {
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      yubikey-touch-detector = {
        enable = true;
      };
    };

    # Upstream sets no Restart=, so a crash/stop leaves it dead until next login.
    systemd.user.services.yubikey-touch-detector.serviceConfig.Restart = "on-failure";

    environment.systemPackages = with pkgs; [
      yubioath-flutter
      yubikey-manager
      pam_u2f
      yubikey-touch-detector
    ];
  };
}

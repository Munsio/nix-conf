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

    environment.systemPackages = with pkgs; [
      yubioath-flutter
      yubikey-manager
      pam_u2f
      yubikey-touch-detector
    ];
  };
}

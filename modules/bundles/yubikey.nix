{pkgs, ...}: {
  # Services for Yubikey
  services = {
    # SmartCard service, needed for USB detection.
    pcscd.enable = true;
    # Yubikey-Agent is for passing SSH keys.
    yubikey-agent.enable = true;
    # Udev rules for Yubikey
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
    yubioath-flutter # gui for managing Yubikey
    yubikey-manager # cli for managing Yubikey. "ykman"
    pam_u2f # yubikey with sudo
    yubikey-touch-detector
  ];
}

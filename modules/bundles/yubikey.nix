{ pkgs, ... }: {
  # SmartCard service, needed for USB detection.
  services.pcscd.enable = true;
  # Yubikey-Agent is for passing SSH keys.
  services.yubikey-agent.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    yubioath-flutter # gui for managing Yubikey
    yubikey-manager # cli for managing Yubikey. "ykman"
    pam_u2f # yubikey with sudo
  ];

}

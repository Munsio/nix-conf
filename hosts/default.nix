{
  lib,
  hostVars,
  pkgs,
  ...
}: {
  # Common configuration for all hosts

  # Enable NixOS modules
  nixModules = {
    # Enable features
    nixos.enable = true;
    nh.enable = true;
  };

  # Set your time zone
  time.timeZone = lib.mkDefault hostVars.timezone;

  # Select internationalisation properties
  i18n = {
    defaultLocale = lib.mkDefault hostVars.locale;
    extraLocaleSettings = lib.mkDefault {
      LC_NUMERIC = hostVars.extraLocale;
      LC_TIME = hostVars.extraLocale;
      LC_MONETARY = hostVars.extraLocale;
      LC_ADDRESS = hostVars.extraLocale;
      LC_IDENTIFICATION = hostVars.extraLocale;
      LC_MEASUREMENT = hostVars.extraLocale;
      LC_PAPER = hostVars.extraLocale;
      LC_TELEPHONE = hostVars.extraLocale;
      LC_NAME = hostVars.extraLocale;
    };
  };

  # Configure console keymap
  console.keyMap = lib.mkDefault hostVars.keyboardLayout;

  # Environment and standard packages
  environment.systemPackages = with pkgs; [
    dmidecode
    fzf
    htop
    killall
    pciutils
    usbutils
    wget
  ];

  services.dbus.enable = true;

  # Security
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  # Firmware update
  services.fwupd.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software.
  system.stateVersion = lib.mkDefault hostVars.stateVersion;
}

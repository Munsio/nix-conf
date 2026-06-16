{lib, ...}: {
  flake.nixosModules.common = {pkgs, ...}: {
    time.timeZone = lib.mkDefault "Europe/Vienna";

    i18n = {
      defaultLocale = lib.mkDefault "en_US.UTF-8";
      extraLocaleSettings = lib.mkDefault {
        LC_NUMERIC = "de_AT.UTF-8";
        LC_TIME = "de_AT.UTF-8";
        LC_MONETARY = "de_AT.UTF-8";
        LC_ADDRESS = "de_AT.UTF-8";
        LC_IDENTIFICATION = "de_AT.UTF-8";
        LC_MEASUREMENT = "de_AT.UTF-8";
        LC_PAPER = "de_AT.UTF-8";
        LC_TELEPHONE = "de_AT.UTF-8";
        LC_NAME = "de_AT.UTF-8";
      };
    };

    console.keyMap = lib.mkDefault "us";

    environment.systemPackages = with pkgs; [
      dmidecode
      fzf
      btop
      killall
      pciutils
      usbutils
      wget
    ];

    services.dbus.enable = true;

    security = {
      rtkit.enable = true;
      polkit.enable = true;
    };

    services.fwupd.enable = true;

    system.stateVersion = lib.mkDefault "26.05";
  };
}

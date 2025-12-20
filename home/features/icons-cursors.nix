{
  pkgs,
  lib,
  ...
}: {
  # Configure icons and themes
  home.packages = [
    # Zafiro icons
    pkgs.zafiro-icons
    # Breeze dark theme
    pkgs.kdePackages.breeze-gtk
  ];

  # Set GTK theme and icons
  gtk = {
    enable = true;
    theme = {
      name = lib.mkForce "Breeze-Dark";
      package = lib.mkForce pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "Zafiro-icons-Dark";
      package = pkgs.zafiro-icons;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };
}

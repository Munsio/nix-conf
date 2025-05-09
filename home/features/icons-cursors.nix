{pkgs, ...}: {
  # Configure icons and themes
  home.packages = [
    # Zafiro icons
    pkgs.zafiro-icons
    # Breeze dark theme
    pkgs.libsForQt5.breeze-gtk
  ];

  # Set GTK theme and icons
  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.libsForQt5.breeze-gtk;
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

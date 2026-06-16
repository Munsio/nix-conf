{...}: {
  flake.homeModules.icons-cursors = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [
      pkgs.zafiro-icons
      pkgs.kdePackages.breeze-gtk
    ];

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
  };
}

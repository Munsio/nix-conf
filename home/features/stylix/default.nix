{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = false;
    image = ./wallpapers/nord-trees.jpg;
    polarity = "dark";

    targets = {
      hyprland = {
        enable = true;
        hyprpaper.enable = true;
      };
      hyprlock.enable = true;
      ghostty.enable = false;

      # TODO: Check because of side effects to other stuff (zen-browser/hyprpanel)
      gtk.enable = false;
      qt.enable = false;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sizes = {
        applications = 10;
        terminal = 14;
        desktop = 10;
        popups = 10;
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 22;
    };
  };
}

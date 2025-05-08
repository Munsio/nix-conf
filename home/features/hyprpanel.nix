{...}: {
  # Enable HyprPanel in home-manager
  programs.hyprpanel = {
    enable = true;

    hyprland.enable = true;

    overwrite.enable = true;
  };
}

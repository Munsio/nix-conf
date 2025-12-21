{...}: {
  homeModules = {
    # Enable Hyprland features
    hyprland.enable = true;
    hyprlock.enable = true;
    hyprpaper.enable = true;
    #hyprpanel.enable = true;
    #quickshell.enable = true;
    noctalia.enable = true;

    # Enable icons and cursors
    icons-cursors.enable = true;
    stylix.enable = true;

    # Enable Hyprland services
    services.hypridle.enable = true;
    services.wayland-idle-inhibitor.enable = true;
  };
}

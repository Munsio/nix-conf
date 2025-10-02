{
  lib,
  config,
  hostVars,
  ...
}: {
  # Enable Home Manager modules using homeModules
  homeModules = {
    bundles.hypr-desktop.enable = true;
  };

  # Add a keybinding for the power menu to Hyprland if it's enabled
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    monitor = [
      "desc:AOC U34G2G1 0x00001BA3, 3440x1440@99.98, 0x0, 1"
      "desc:BOE 0x0BFB, 1920x1200@60, 3440x220, 1"
    ];

    # Set external monitor as "main"
    #workspace = ["1, monitor:DP-3"];
    #exec-once = ["hyprctl dispatch workspace 1"];
  };
}

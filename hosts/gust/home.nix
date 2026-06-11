{
  lib,
  config,
  ...
}: {
  # Enable Home Manager modules using homeModules
  homeModules = {
    bundles.hypr-desktop.enable = true;
  };

  # Add a keybinding for the power menu to Hyprland if it's enabled
  wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
    hl.monitor({ output = "desc:AOC U34G2G1 0x00001BA3", mode = "3440x1440@99.98", position = "0x0", scale = 1 })
    hl.monitor({ output = "desc:BOE 0x0BFB", mode = "1920x1200@60", position = "3440x220", scale = 1 })
  '';
}

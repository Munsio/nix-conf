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
    hl.monitor({ output = "desc:BOE NE135A1M-NY1", mode = "2880x1920@120.00", position = "3440x220", scale = 2 })
    hl.workspace_rule({ workspace = "1", monitor = "DP-3" })
    hl.on("hyprland.start", function()
      hl.exec_cmd("hyprctl dispatch workspace 1")
    end)
  '';
}

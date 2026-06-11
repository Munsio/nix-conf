{
  config,
  lib,
  ...
}: let
  cfg = config.homeModules.hyprland;
  luaConfig = builtins.replaceStrings ["__TERMINAL__"] [cfg.terminal] (builtins.readFile ../hyprland.lua);
in {
  options.homeModules.hyprland.terminal = lib.mkOption {
    type = lib.types.str;
    default = "kitty";
    description = "Terminal emulator to use in hyprland keybindings";
  };

  config = {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd = {
        enable = true;
        variables = ["--all"];
      };
      package = null;
      portalPackage = null;
      extraConfig = luaConfig;
    };
  };
}

{lib, ...}: {
  flake.homeModules.hyprland = {config, ...}: let
    terminal = config.hyprland-terminal or "kitty";
    luaConfig = builtins.replaceStrings ["__TERMINAL__"] [terminal] (builtins.readFile ../hyprland.lua);
  in {
    options.hyprland-terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
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
  };
}

{lib, ...}: {
  flake.nixosModules.hyprland = {pkgs, ...}: {
    programs.hyprland = {
      enable = true;
      package = pkgs.unstable.hyprland;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      unstable.hyprlock
      unstable.hypridle
      unstable.hyprpaper
      wl-clipboard
      wlinhibit
    ];
  };

  flake.homeModules.hyprland = {config, ...}: let
    terminal = config.hyprland-terminal;
    luaConfig = builtins.replaceStrings ["__TERMINAL__"] [terminal] (builtins.readFile ./hyprland.lua);
  in {
    options.hyprland-terminal = lib.mkOption {
      type = lib.types.str;
      default = config.home.sessionVariables.TERMINAL;
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

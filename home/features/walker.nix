{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  walkerConfig =
    (lib.importTOML "${inputs.walker}/internal/config/config.default.toml")
    // {
      app_launch_prefix = "systemd-run --user ";

      plugins = [
        {
          keep_sort = true;
          name = "power";
          placeholder = "Power";
          recalculate_score = true;
          show_icon_when_single = true;
          switcher_only = true;
          entries = [
            {
              exec = "playerctl --all-players pause & hyprlock";
              icon = "system-lock-screen";
              label = "Lock Screen";
            }
            {
              exec = "hyprctl dispatch exit";
              icon = "system-logout";
              label = "Logout";
            }
            {
              exec = "loginctl lock-session; sleep 1; systemctl suspend";
              icon = "system-suspend";
              label = "Suspend";
            }
            {
              exec = "shutdown now";
              icon = "system-shutdown";
              label = "Shutdown";
            }
            {
              exec = "reboot";
              icon = "system-reboot";
              label = "Reboot";
            }
          ];
        }
      ];
    };
in {
  programs.walker = {
    enable = true;
    #runAsService = true;

    config = walkerConfig;
  };

  systemd.user.services.walker = {
    Unit.Description = "Walker - Application Runner";
    Install.WantedBy = ["graphical-session.target"];
    Service = {
      ExecStart = "${inputs.walker.packages.${pkgs.system}.default}/bin/walker --gapplication-service";
      Restart = "on-failure";
      Environment = "GSK_RENDERER=cairo";
    };
  };

  # Add a keybinding for walker to Hyprland if it's enabled
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = [
      "alt, space, exec, walker" # Standard Walker menu
      "$mod, l, exec, walker -m power" # Power menu
      "ctrl_alt, v, exec, walker -m clipboard" # Plasma style clipboard menu
    ];
  };
}

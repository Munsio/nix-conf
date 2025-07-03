{
  lib,
  config,
  pkgs,
  ...
}: let
  theme = builtins.fromJSON (builtins.readFile "${pkgs.hyprpanel}/share/themes/everforest.json");
in {
  # Enable HyprPanel in home-manager
  programs.hyprpanel = {
    enable = true;

    systemd.enable = true;

    settings =
      {
        bar.layouts = {
          "0" = {
            left = ["dashboard" "workspaces" "windowtitle"];
            middle = ["media"];
            right = [
              "volume"
              "network"
              "bluetooth"
              "battery"
              "systray"
              "clock"
              "notifications"
            ];
          };
        };

        bar = {
          clock.format = "%a %b %d  %H:%M:%S %p";
          launcher.autoDetectIcon = true;

          workspaces.show_icons = true;
        };

        menus.clock = {
          time.military = true;

          weather = {
            enabled = false;
          };
        };
      }
      // theme;
  };

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  # Add a keybinding for hyprpanel to Hyprland if it's enabled
  wayland.windowManager.hyprland.settings = lib.mkIf (config.programs.hyprpanel.enable && config.wayland.windowManager.hyprland.enable) {
    bind = [
      "$mod CTRL SHIFT, P, exec, systemctl restart hyprpanel --user"
    ];
  };
}

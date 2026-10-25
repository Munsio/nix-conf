{...}: {
  flake.homeModules.noctalia = {
    inputs,
    config,
    lib,
    pkgs,
    ...
  }: let
    # Hide lock-screen power buttons; monitors without a box here get a default one that shows them.
    loginBox = output: cx: cy: {
      type = "login_box";
      inherit output cx cy;
      settings.show_session_buttons = false;
    };
  in {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = true;
      settings = {
        shell = {
          corner_radius_scale = 0.2;
          avatar_path = "${config.home.homeDirectory}/.face";
        };

        theme = {
          mode = "dark";
          source = "community";
          community_palette = "Everforest";
        };

        bar.main = {
          position = "top";
          capsule = false;
          widget_spacing = 12;
          start = ["control-center" "network" "bluetooth"];
          center = ["workspaces"];
          end = ["battery" "notifications" "volume" "clock" "tailscale"];
        };

        widget = {
          control-center.custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          workspaces = {
            show_labels = false;
            hide_when_empty = false;
          };
          battery.show_label = false;
          clock = {
            format = "{:%d %b - %H:%M}";
            vertical_format = "{:%H\n%M}";
          };
          tailscale.type = "davemhammer/tailscale:status";
        };

        battery.warning_threshold = 30;

        wallpaper.enabled = false;
        dock.enabled = false;

        notification.position = "top_right";
        osd.position = "top_center";

        lockscreen.fingerprint = true;
        lockscreen_widgets.widget = {
          "lockscreen-login-box@eDP-1" = loginBox "eDP-1" 720.0 760.0;
          "lockscreen-login-box@DP-3" = loginBox "DP-3" 1720.0 1240.0;
        };

        # Replaces hypridle: mirrors its former listener timeouts/actions.
        idle = {
          pre_action_fade_seconds = 5.0;
          behavior_order = ["dim" "lock" "screen-off" "suspend"];
          behavior = {
            dim = {
              timeout = 150;
              action = "command";
              command = "brightnessctl -s set 10";
              resume_command = "brightnessctl -r";
            };
            lock = {
              timeout = 900;
              action = "lock";
            };
            screen-off = {
              timeout = 1200;
              action = "screen_off";
              resume_command = "brightnessctl -r";
            };
            suspend = {
              timeout = 1800;
              action = "lock_and_suspend";
            };
          };
        };

        location.address = "Linz, Austria";
        control_center.calendar.show_week_numbers = true;

        plugins.enabled = [
          "davemhammer/tailscale"
          "dotnetrob/cat"
        ];
      };
    };

    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("noctalia")
      end)
    '';
  };
}

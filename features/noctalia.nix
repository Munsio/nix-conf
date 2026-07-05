{...}: {
  flake.homeModules.noctalia = {
    inputs,
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;
      settings = {
        bar = {
          density = "default";
          position = "top";
          showCapsule = false;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                id = "Network";
              }
              {
                id = "Bluetooth";
              }
            ];
            center = [
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              {
                alwaysShowPercentage = false;
                id = "Battery";
                warningThreshold = 30;
              }
              {
                id = "NotificationHistory";
              }
              {
                id = "Volume";
              }
              {
                formatHorizontal = "dd MMM - HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
              {
                id = "plugin:tailscale";
              }
            ];
          };
        };
        wallpaper = {
          enabled = false;
        };
        dock = {
          enabled = false;
        };
        notifications = {
          location = "top_center";
        };
        osd = {
          location = "top_center";
        };
        colorSchemes.predefinedScheme = "Everforest";
        general = {
          avatarImage = "/home/drfoobar/.face";
          radiusRatio = 0.2;
        };
        location = {
          monthBeforeDay = false;
          name = "Linz, Austria";
          showWeekNumberInCalendar = true;
          firstDayOfWeek = 1;
        };
      };

      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          catwalk = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          tailscale = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
        version = 2;
      };

      pluginSettings = {
        tailscale = {
          terminalCommand = "kitty";
        };
      };
    };

    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("noctalia-shell")
      end)
    '';
  };
}

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
          location = "top_right";
        };
        osd = {
          location = "top_center";
        };
        colorSchemes.predefinedScheme = "Everforest";
        general = {
          avatarImage = "/home/drfoobar/.face";
          radiusRatio = 0.2;
          allowPasswordWithFprintd = true;
          autoStartAuth = true;
          # Power buttons on the lock screen let anyone with physical access
          # suspend/reboot/shutdown before authenticating. Never expose them.
          showSessionButtonsOnLockScreen = false;
        };
        # Replaces hypridle: mirrors its former listener timeouts/actions.
        idle = {
          enabled = true;
          screenOffTimeout = 1200;
          lockTimeout = 900;
          suspendTimeout = 1800;
          fadeDuration = 5;
          resumeScreenOffCommand = "brightnessctl -r";
          customCommands = builtins.toJSON [
            {
              timeout = 150;
              command = "brightnessctl -s set 10";
              resumeCommand = "brightnessctl -r";
            }
          ];
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
          terminalCommand = config.home.sessionVariables.TERMINAL;
        };
      };
    };

    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("noctalia-shell")
      end)
    '';

    # `noctalia-shell ipc call <target> <fn>` resolves its own baked-in
    # config name to an absolute nix store path and only matches a running
    # instance registered under that exact path. home-manager rebuilds
    # noctalia-shell into a new store path on almost every settings change,
    # so this breaks the moment you rebuild without restarting the shell:
    # the CLI looks for a path nothing is running under anymore, even
    # though noctalia-shell is alive and well under its old (still valid)
    # path. Sidestep this by finding the live quickshell process directly
    # and targeting it by pid, using its own binary as the IPC client
    # (always protocol-compatible with itself, regardless of store-path
    # drift). Used by fuzzel's power menu and Hyprland lock/idle keybinds
    # instead of calling `noctalia-shell ipc call` directly.
    home.file.".local/bin/noctalia-ipc" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        pid=$(pgrep -f '/bin/quickshell$' | head -n1)
        if [ -z "$pid" ]; then
          echo "noctalia-ipc: quickshell is not running" >&2
          exit 1
        fi
        exe=$(readlink -f "/proc/$pid/exe")
        exec "$exe" ipc --pid "$pid" call "$@"
      '';
    };
  };
}

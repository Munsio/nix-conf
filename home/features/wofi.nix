{
  lib,
  config,
  ...
}: {
  # Configure wofi - a Wayland native application launcher
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 32;
      gtk_dark = true;
    };

    # Custom styling
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 14px;
      }

      window {
        margin: 0px;
        padding: 10px;
        border: 2px solid #8aadf4;
        border-radius: 8px;
        background-color: rgba(30, 30, 46, 0.95);
        animation: slideIn 0.2s ease-in-out both;
      }

      @keyframes slideIn {
        0% {
          opacity: 0;
          transform: translateY(-20px);
        }
        100% {
          opacity: 1;
          transform: translateY(0);
        }
      }

      #input {
        margin: 5px;
        padding: 8px 12px;
        border: none;
        border-radius: 6px;
        color: #cad3f5;
        background-color: #363a4f;
      }

      #inner-box {
        margin: 5px;
        padding: 5px;
        border: none;
        background-color: transparent;
      }

      #outer-box {
        margin: 5px;
        padding: 5px;
        border: none;
        background-color: transparent;
      }

      #scroll {
        margin: 0px;
        padding: 5px;
        border: none;
      }

      #text {
        margin: 5px;
        padding: 5px;
        border: none;
        color: #cad3f5;
      }

      #entry {
        padding: 5px;
        border-radius: 6px;
      }

      #entry:selected {
        background-color: #494d64;
      }

      #entry:selected #text {
        color: #8aadf4;
      }
    '';
  };

  # Create files for wofi
  home.file = {
    # Create a directory for custom scripts
    ".local/bin/.keep".text = "";

    # Create the power menu script
    ".local/bin/wofi-power-menu" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Power menu options
        entries="󰤄 Logout\n󰒲 Suspend\n󰑓 Reboot\n⏻ Shutdown"

        # Use wofi to display the power menu
        selected=$(echo -e $entries | wofi --dmenu --cache-file /dev/null --insensitive --width 250 --height 210 --location center --prompt "Power Menu" --style ~/.config/wofi/power-menu.css)

        # Execute the selected command
        case $selected in
            "󰤄 Logout")
                hyprctl dispatch exit
                ;;
            "󰒲 Suspend")
                systemctl suspend
                ;;
            "󰑓 Reboot")
                systemctl reboot
                ;;
            "⏻ Shutdown")
                systemctl poweroff
                ;;
        esac
      '';
    };

    # Create a custom style for the power menu
    ".config/wofi/power-menu.css" = {
      text = ''
        * {
          font-family: "JetBrainsMono Nerd Font", sans-serif;
          font-size: 16px;
        }

        window {
          margin: 0px;
          padding: 10px;
          border: 2px solid #f5a97f;
          border-radius: 8px;
          background-color: rgba(30, 30, 46, 0.95);
          animation: slideIn 0.2s ease-in-out both;
        }

        @keyframes slideIn {
          0% {
            opacity: 0;
            transform: scale(0.9);
          }
          100% {
            opacity: 1;
            transform: scale(1.0);
          }
        }

        #input {
          margin: 5px;
          padding: 8px 12px;
          border: none;
          border-radius: 6px;
          color: #cad3f5;
          background-color: #363a4f;
        }

        #inner-box {
          margin: 5px;
          padding: 5px;
          border: none;
          background-color: transparent;
        }

        #outer-box {
          margin: 5px;
          padding: 5px;
          border: none;
          background-color: transparent;
        }

        #scroll {
          margin: 0px;
          padding: 5px;
          border: none;
        }

        #text {
          margin: 5px;
          padding: 5px;
          border: none;
          color: #cad3f5;
        }

        #entry {
          padding: 8px;
          border-radius: 6px;
        }

        #entry:selected {
          background-color: #494d64;
        }

        #entry:selected #text {
          color: #f5a97f;
        }
      '';
    };
  };

  # Add a keybinding for the power menu to Hyprland if it's enabled
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    windowrule = ["animation none, Wofi"];

    bind = [
      "ALT, Space, exec, killall wofi || wofi"
      "$mod, escape, exec, ~/.local/bin/wofi-power-menu"
    ];
  };

  # Ensure the .local/bin directory is in the PATH
  home.sessionVariables = {PATH = "$HOME/.local/bin:$PATH";};
}

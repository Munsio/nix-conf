{
  lib,
  config,
  ...
}: let
  background = "#${config.lib.stylix.colors.base00}";
  background-alt = "#${config.lib.stylix.colors.base01}";
  foreground = "#${config.lib.stylix.colors.base05}";
in {
  # Configure wofi - a Wayland native application launcher
  programs.wofi = {
    enable = true;
    settings = {
      width = "30%";
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      key_expand = "Tab";
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
      window {
        min-width: 20%;
        margin: 0px;
        background-color: transparent;
      }

      #input {
        border: none;
        border-radius: 0px;
        background-color: ${background};
        outline: none;
        color: ${foreground};
        border-bottom: 1px solid ${background-alt};
        margin-bottom: 5px;
      }

      #input:focus {
        outline: none;
        box-shadow: none;
      }

      #inner-box {
        padding-bottom: 5px;
        background-color: ${background};
      }

      #outer-box {
        padding: 10px;
        border: 1px solid ${background-alt};
        background-color: ${background};
        border-radius: 10px;
      }

      #text {
        padding-left: 5px;
        color: ${foreground};
      }

      #entry {
        padding: 8px;
        outline: none;
        border-radius: 5px;
      }

      #entry:selected {
        background-color: ${background-alt};
      }
    '';
  };

  # Create files for wofi
  home.file = {
    # Create the power menu script
    ".local/bin/wofi-power-menu" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Power menu options
        entries="󰌾 Lock\n󰤄 Logout\n󰒲 Suspend\n󰑓 Reboot\n⏻ Shutdown"

        # Use wofi to display the power menu
        selected=$(echo -e $entries | wofi --dmenu --cache-file /dev/null --prompt "Power Menu")

        # Execute the selected command
        case $selected in
            "󰌾 Lock")
                loginctl lock-session
                ;;
            "󰤄 Logout")
                hyprctl dispatch exit
                ;;
            "󰒲 Suspend")
                loginctl lock-session; sleep 1; systemctl suspend
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
  };

  # Add a keybinding for the power menu to Hyprland if it's enabled
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = [
      "ALT, Space, exec, killall wofi || wofi"
      "$mod, escape, exec, ~/.local/bin/wofi-power-menu"
    ];
  };

  # Ensure the .local/bin directory is in the PATH
  home.sessionVariables = {PATH = "$HOME/.local/bin:$PATH";};
}

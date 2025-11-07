{
  lib,
  config,
  ...
}: let
  background = "#${config.lib.stylix.colors.base00}";
  background-alt = "#${config.lib.stylix.colors.base01}";
  foreground = "#${config.lib.stylix.colors.base05}";
in {
  # Enable Fuzzel dmenu
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font Mono:size 12";
        dpi-aware = "yes";
        icon-theme = "Zafiro-icons-Dark";
        terminal = "ghostty -e";
        inner-pad = 10;
      };

      colors = {
        background = "${background}ff";
        text = "${foreground}ff";
        selection = "${background-alt}ff";
        selection-text = "${foreground}ff";
        border = "${background-alt}ff";
      };
    };
  };

  # Create the power menu script
  home.file.".local/bin/fuzzel-power-menu" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Power menu options
      entries="󰌾 Lock\n󰤄 Logout\n󰒲 Suspend\n󰑓 Reboot\n⏻ Shutdown"

      # Use fuzzel to display the power menu
      selected=$(echo -e $entries | fuzzel --dmenu)

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

  # Add a keybinding for the power menu to Hyprland if it's enabled
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = [
      "alt, space, exec, fuzzel"
      "$mod, l, exec, loginctl lock-session" # Lock session
      "$mod, escape, exec, ~/.local/bin/fuzzel-power-menu"
      "ctrl_alt, v, exec, clipman pick --tool=CUSTOM --tool-args='fuzzel -w 100 -d'" # Plasma style clipboard menu
    ];

    layerrule = [
      "noanim, launcher"
    ];
  };

  # Ensure the .local/bin directory is in the PATH
  home.sessionVariables = {PATH = "$HOME/.local/bin:$PATH";};
}

{...}: {
  flake.homeModules.fuzzel = {
    config,
    lib,
    ...
  }: let
    background = "#${config.lib.stylix.colors.base00}";
    background-alt = "#${config.lib.stylix.colors.base01}";
    foreground = "#${config.lib.stylix.colors.base05}";
  in {
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

    home.file.".local/bin/fuzzel-power-menu" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        entries="󰌾 Lock\n󰤄 Logout\n󰒲 Suspend\n󰑓 Reboot\n⏻ Shutdown"

        selected=$(echo -e $entries | fuzzel --dmenu)

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

    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      hl.bind("ALT + space", hl.dsp.exec_cmd("fuzzel"))
      hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"), { locked = true })
      hl.bind("SUPER + escape", hl.dsp.exec_cmd("~/.local/bin/fuzzel-power-menu"))
      hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd("clipman pick --tool=CUSTOM --tool-args='fuzzel -w 100 -d'"))
      hl.layer_rule({ match = { namespace = "launcher" }, no_anim = true })
    '';

    home.sessionVariables = {PATH = "$HOME/.local/bin:$PATH";};
  };
}

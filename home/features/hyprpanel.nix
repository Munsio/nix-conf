{...}: let
  # accent = "#${config.lib.stylix.colors.base0D}";
  # accent-alt = "#${config.lib.stylix.colors.base03}";
  # background = "#${config.lib.stylix.colors.base00}";
  # background-alt = "#${config.lib.stylix.colors.base01}";
  # foreground = "#${config.lib.stylix.colors.base05}";
in {
  # Enable HyprPanel in home-manager
  programs.hyprpanel = {
    enable = true;

    hyprland.enable = true;

    overwrite.enable = true;

    settings = {
      layout = {
        "bar.layouts" = {
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

      theme.name = "everforest";
    };

    # TODO: Set colors based upon stylix configuration.
    override = {
      # "theme.bar.background" = "${background-alt}";
      # "theme.bar.buttons.text" = "${foreground}";
      # "theme.bar.buttons.background" = "${background}";
      # "theme.bar.menus.background" = "${background}";
      # "theme.bar.menus.cards" = "${background-alt}";
      # "theme.bar.menus.label" = "${foreground}";
      # "theme.bar.menus.text" = "${foreground}";
      # "theme.bar.menus.border.color" = "${accent}";
      # "theme.bar.menus.popover.text" = "${foreground}";
      # "theme.bar.menus.popover.background" = "${background-alt}";
      # "theme.bar.menus.listitems.active" = "${accent}";
      # "theme.bar.menus.icons.active" = "${accent}";
      # "theme.bar.menus.switch.enabled" = "${accent}";
      # "theme.bar.menus.check_radio_button.active" = "${accent}";
      # "theme.bar.menus.buttons.default" = "${accent}";
      # "theme.bar.menus.buttons.active" = "${accent}";
      # "theme.bar.menus.iconbuttons.active" = "${accent}";
      # "theme.bar.menus.progressbar.foreground" = "${accent}";
      # "theme.bar.menus.slider.primary" = "${accent}";
      # "theme.bar.menus.tooltip.background" = "${background-alt}";
      # "theme.bar.menus.tooltip.text" = "${foreground}";
      # "theme.bar.menus.dropdownmenu.background" = "${background-alt}";
      # "theme.bar.menus.dropdownmenu.text" = "${foreground}";
      # "theme.bar.buttons.icon" = "${accent}";
      # "theme.bar.buttons.notifications.background" = "${background-alt}";
      # "theme.bar.buttons.hover" = "${background}";
      # "theme.bar.buttons.notifications.hover" = "${background}";
      # "theme.bar.buttons.notifications.total" = "${accent}";
      # "theme.bar.buttons.notifications.icon" = "${accent}";
      # "theme.osd.bar_color" = "${accent}";
      # "theme.osd.bar_overflow_color" = "${accent-alt}";
      # "theme.osd.icon" = "${background}";
      # "theme.osd.icon_container" = "${accent}";
      # "theme.osd.label" = "${accent}";
      # "theme.osd.bar_container" = "${background-alt}";
      # "theme.bar.menus.menu.media.background.color" = "${background-alt}";
      # "theme.bar.menus.menu.media.card.color" = "${background-alt}";
      # "theme.notification.background" = "${background-alt}";
      # "theme.notification.actions.background" = "${accent}";
      # "theme.notification.actions.text" = "${foreground}";
      # "theme.notification.label" = "${accent}";
      # "theme.notification.border" = "${background-alt}";
      # "theme.notification.text" = "${foreground}";
      # "theme.notification.labelicon" = "${accent}";
      # "theme.notification.close_button.background" = "${background-alt}";
    };
  };
}

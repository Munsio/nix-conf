{...}: {
  flake.homeModules.kitty = {config, ...}: {
    programs.kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;

      themeFile = "Catppuccin-Frappe";
      settings = {
        font_family = "${config.stylix.fonts.monospace.name}";
        font_size = config.stylix.fonts.sizes.terminal;

        background = "#282c34";
        foreground = "#abb2bf";

        window_padding_width = "5 10";

        scrollback_lines = 10000;
      };
    };
  };
}

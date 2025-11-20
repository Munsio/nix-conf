{
  lib,
  pkgs,
  config,
  hostVars,
  ...
}: {
  programs.kitty =
    {
      enable = true;
      shellIntegration.enableFishIntegration = true;

      themeFile = "Catppuccin-Frappe";
      settings = {
        font_family = "${config.stylix.fonts.monospace.name}";
        font_size = config.stylix.fonts.sizes.terminal;

        # Theme configuration
        background = "#282c34";
        foreground = "#abb2bf";

        window_padding_width = "5 10";

        # Scrollback
        scrollback_lines = 10000;
      };
    }
    // lib.optionalAttrs (!hostVars.isNixOS) {
      package = pkgs.emptyDirectory;
    };
}

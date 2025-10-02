{
  lib,
  config,
  pkgs,
  ...
}: {
  # Enable Ghostty terminal in home-manager
  programs.ghostty = {
    enable = true;
    package = pkgs.unstable.ghostty;
    enableFishIntegration = lib.mkIf config.programs.fish.enable true;

    # Basic configuration
    settings = {
      # Font configuration
      font-family = "JetBrainsMono Nerd Font Mono";
      font-size = 12;

      # Window configuration
      window-padding-x = 10;
      window-padding-y = 10;

      # Theme configuration
      background = "#282c34";
      foreground = "#abb2bf";

      # Cursor configuration
      cursor-style = "block";

      # Scrollback
      scrollback-limit = 10000;
    };
  };
}

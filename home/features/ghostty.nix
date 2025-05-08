{...}: {
  # Enable Ghostty terminal in home-manager
  programs.ghostty = {
    enable = true;
    # Basic configuration
    settings = {
      # Font configuration
      font-family = "JetBrains Mono";
      font-size = 12;

      # Window configuration
      window-padding-x = 10;
      window-padding-y = 10;

      # Theme configuration
      background = "#282c34";
      foreground = "#abb2bf";

      # Cursor configuration
      cursor-style = "block";
      cursor-blink-interval-ms = 750;

      # Scrollback
      scrollback-lines = 10000;
    };
  };
}

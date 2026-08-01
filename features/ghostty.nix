{...}: {
  flake.homeModules.ghostty = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.ghostty = {
      enable = true;
      package = pkgs.unstable.ghostty;
      enableFishIntegration = lib.mkIf config.programs.fish.enable true;

      settings = {
        font-family = "JetBrainsMono Nerd Font Mono";
        font-size = 12;

        window-padding-x = 10;
        window-padding-y = 10;

        background = "#282c34";
        foreground = "#abb2bf";

        cursor-style = "block";

        scrollback-limit = 10000;

        # Auto-downgrade TERM to xterm-256color over SSH instead of xterm-ghostty,
        # since remote hosts usually lack Ghostty's terminfo entry.
        shell-integration-features = "ssh-env";
      };
    };
  };
}

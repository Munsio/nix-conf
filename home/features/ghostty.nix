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
      };
    };
  };
}

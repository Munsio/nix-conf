{
  lib,
  config,
  ...
}: {
  homeModules = {
    discord.enable = true;
    moonlight.enable = true;
    nvf.enable = true;
    rustdesk.enable = true;
    services.flameshot.enable = true;
    signal-desktop.enable = true;
    ghostty.enable = true;
  };

  ## Git
  programs = {
    git = lib.mkIf config.homeModules.git.enable {
      userEmail = "git@treml.dev";
      userName = "Martin Treml";
    };
  };
}

{
  lib,
  config,
  ...
}: {
  homeModules = {
    discord.enable = true;
    moonlight.enable = true;
    signal-desktop.enable = true;
    ghostty.enable = true;
    zen-browser.enable = true;
  };

  ## Git
  programs = {
    git = lib.mkIf config.homeModules.git.enable {
      settings.user.email = "git@treml.dev";
      settings.user.name = "Martin Treml";
    };
  };

  ## Private SSH Key
  sops.secrets = {
    "ssh_keys/martin/private" = {
      path = "/home/martin/.ssh/id_ed25519";
    };
    "ssh_keys/martin/public" = {
      path = "/home/martin/.ssh/id_ed25519.pub";
    };
  };

  ## Custom Mime Apps
  xdg = {
    mimeApps = {
      enable = true;
      associations.added = {
        "application/json" = ["zen-twilight.desktop"];
        "application/pdf" = ["zen-twilight.desktop"];
        "application/x-extension-htm" = ["zen-twilight.desktop"];
        "application/x-extension-html" = ["zen-twilight.desktop"];
        "application/x-extension-shtml" = ["zen-twilight.desktop"];
        "application/x-extension-xht" = ["zen-twilight.desktop"];
        "application/x-extension-xhtml" = ["zen-twilight.desktop"];
        "application/xhtml+xml" = ["zen-twilight.desktop"];
        "text/html" = ["zen-twilight.desktop"];
        "text/plain" = ["zen-twilight.desktop"];
        "x-scheme-handler/about" = ["zen-twilight.desktop"];
        "x-scheme-handler/chrome" = ["zen-twilight.desktop"];
        "x-scheme-handler/http" = ["zen-twilight.desktop"];
        "x-scheme-handler/https" = ["zen-twilight.desktop"];
        "x-scheme-handler/mailto" = ["zen-twilight.desktop"];
        "x-scheme-handler/unknown" = ["zen-twilight.desktop"];
      };
    };
  };
}

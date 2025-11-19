{
  lib,
  config,
  ...
}: {
  ## GDM environment variable fix.
  home.file.".config/environment.d/envvars.conf".text = ''
    PATH=$PATH:${config.home.homeDirectory}/.nix-profile/bin
  '';

  ## Git
  programs = {
    git = lib.mkIf config.homeModules.git.enable {
      userEmail = "martin.treml@agilox.net";
      userName = "Martin Treml";
    };

    fish = lib.mkIf config.homeModules.fish.enable {
      shellAliases = {
        dev = "just -f /home/martin/Documents/projects/developer-toolbox/justfile";
      };
    };
  };

  ## Hyprland Jetbrains specific stuff
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    windowrule = [
      # workaround for jetbrains IDEs dropdowns/popups cause flickering
      "noinitialfocus, class:^(.*jetbrains.*)$, title:^(win.*)$"
    ];
  };
}

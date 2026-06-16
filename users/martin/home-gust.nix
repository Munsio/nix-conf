{...}: {
  flake.homeModules.martin-gust = {
    config,
    lib,
    ...
  }: {
    targets.genericLinux.enable = true;

    home.file.".config/environment.d/envvars.conf".text = ''
      PATH=$PATH:${config.home.homeDirectory}/.nix-profile/bin
    '';

    programs = {
      git = lib.mkIf config.programs.git.enable {
        settings.user.email = "martin.treml@agilox.net";
        settings.user.name = "Martin Treml";
      };

      fish = lib.mkIf config.programs.fish.enable {
        shellAliases = {
          dev = "just -f /home/martin/Documents/projects/developer-toolbox/justfile";
        };
      };
    };

    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      hl.window_rule({ match = { class = "^(.*jetbrains.*)$", title = "^(win.*)$" }, no_initial_focus = true })
    '';
  };
}

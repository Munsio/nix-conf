{self, ...}: {
  flake.homeModules.martin-vortex = {
    config,
    lib,
    ...
  }: {
    imports = [
      self.homeModules.zen-browser
    ];

    programs.git = lib.mkIf config.programs.git.enable {
      settings.user.email = "git@treml.dev";
      settings.user.name = "Martin Treml";
    };
  };
}

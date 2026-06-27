{self, ...}: {
  flake.homeModules.martin-vortex = {
    config,
    lib,
    ...
  }: {
    imports = [
      self.homeModules.discord
      self.homeModules.signal-desktop
    ];

    programs.git = lib.mkIf config.programs.git.enable {
      settings.user.email = "git@treml.dev";
      settings.user.name = "Martin Treml";
    };
  };
}

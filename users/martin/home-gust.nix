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
  };
}

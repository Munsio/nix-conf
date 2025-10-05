{
  lib,
  config,
  ...
}: {
  ## Git
  programs = {
    git = lib.mkIf config.homeModules.git.enable {
      userEmail = "martin.treml@agilox.net";
      userName = "Martin Treml";
    };
  };
}

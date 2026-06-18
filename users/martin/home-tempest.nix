{...}: {
  flake.darwinModules.martin-tempest = {
    my.darwinUser.martin.username = "martin.treml";
  };

  flake.homeModules.martin-tempest = {...}: {
    home = {
      username = "martin.treml";
      homeDirectory = "/Users/martin.treml";
    };

    programs.git.extraConfig.user.email = "martin.treml@agilox.net";
  };
}

{...}: {
  flake.darwinModules.martin-treml-user = {
    system.primaryUser = "martin.treml";
    users.users."martin.treml".home = "/Users/martin.treml";
  };
}

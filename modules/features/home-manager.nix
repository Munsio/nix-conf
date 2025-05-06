{ inputs, hostname, hostVars, users, lib, moduleLib, ... }:
let inherit (moduleLib) mkModuleSystem moduleTypes;
in {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs hostname hostVars; };
    sharedModules = [
      (mkModuleSystem {
        featuresDir = ../../home/features;
        bundlesDir = ../../home/bundles;
        servicesDir = ../../home/services;
        type = moduleTypes.home;
      })
    ];
    # Load user-specific home-manager configurations
    users = lib.genAttrs users (user: {
      imports =
        [ ../../hosts/${hostname}/home.nix ../../users/${user}/home.nix ];
      #++ extraHomeManagerModules;
    });
  };
}

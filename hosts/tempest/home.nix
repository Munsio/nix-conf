{
  self,
  inputs,
  ...
}: {
  flake.darwinModules.tempest-home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = {inherit inputs;};
      users."martin.treml" = {
        imports = [
          self.homeModules.martin-treml
          self.homeModules.martin-treml-tempest
        ];
      };
    };
  };
}

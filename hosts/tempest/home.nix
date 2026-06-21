{
  self,
  inputs,
  ...
}: {
  flake.darwinModules.tempest-home-manager = {config, ...}: {
    imports = [
      inputs.home-manager.darwinModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = {inherit inputs;};
      users.${config.my.darwinUser.martin.username}.imports = [
        self.homeModules.martin-darwin
        self.homeModules.martin-tempest
      ];
    };
  };
}

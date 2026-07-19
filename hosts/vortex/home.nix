{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.vortex-home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = {inherit inputs;};
      users.martin.imports = [
        self.homeModules.martin
        self.homeModules.martin-vortex
        self.homeModules.stylix
        self.homeModules.lutris
        inputs.stylix.homeModules.stylix
        inputs.nvf.homeManagerModules.nvf
        inputs.zen-browser-flake.homeModules.twilight
      ];
    };
  };
}

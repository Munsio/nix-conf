{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.squall-home-manager = {
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
        self.homeModules.martin-squall
        self.homeModules.hypr-desktop
        inputs.stylix.homeModules.stylix
        inputs.nvf.homeManagerModules.nvf
        inputs.wayland-pipewire-idle-inhibit.homeModules.default
        inputs.zen-browser-flake.homeModules.twilight
      ];
    };
  };
}

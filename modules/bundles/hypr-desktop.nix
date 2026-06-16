{self, ...}: {
  flake.nixosModules.hypr-desktop = {
    imports = [
      self.nixosModules.hyprland
      self.nixosModules.greetd
    ];
  };
}

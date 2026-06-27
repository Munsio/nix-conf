{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.squall = {pkgs, ...}: {
    imports = [
      self.nixosModules.common
      self.nixosModules.nixos
      self.nixosModules.unstableOverlay
      self.nixosModules.systemd-boot
      self.nixosModules.amdgpu
      self.nixosModules.audio
      self.nixosModules.sunshine
      self.nixosModules.steam
      self.nixosModules.heroic
      self.nixosModules.hypr-desktop
      self.nixosModules.martin-user
      self.nixosModules.squall-home-manager
    ];

    networking.hostName = "squall";
    networking.networkmanager.enable = true;

    services.qemuGuest.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
    ];
  };

  flake.nixosConfigurations.squall = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      self.nixosModules.squall
      ./hardware-configuration.nix
    ];
  };
}

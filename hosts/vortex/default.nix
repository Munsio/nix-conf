{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.vortex = {pkgs, lib, ...}: {
    imports = [
      self.nixosModules.common
      self.nixosModules.nixos
      self.nixosModules.unstableOverlay
      self.nixosModules.systemd-boot
      self.nixosModules.openssh
      self.nixosModules.amdgpu
      self.nixosModules.audio
      self.nixosModules.sunshine
      self.nixosModules.steam
      self.nixosModules.heroic
      self.nixosModules.hypr-desktop
      self.nixosModules.martin-user
      self.nixosModules.vortex-home-manager
    ];

    networking.hostName = "vortex";
    networking.networkmanager.enable = true;

    services.openssh.openFirewall = lib.mkForce true;

    services.qemuGuest.enable = true;
    services.fstrim.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
    ];
  };

  flake.nixosConfigurations.vortex = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      self.nixosModules.vortex
      ./hardware-configuration.nix
    ];
  };
}

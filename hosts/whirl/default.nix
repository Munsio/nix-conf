{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.whirl = {pkgs, ...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      self.nixosModules.common
      self.nixosModules.nixos
      self.nixosModules.nh
      self.nixosModules.sops
      self.nixosModules.openssh
      self.nixosModules.audio
      self.nixosModules.bluetooth
      self.nixosModules.systemd-boot
      self.nixosModules.heroic
      self.nixosModules.steam
      self.nixosModules.proton-vpn
      self.nixosModules.unstableOverlay
      self.nixosModules.automount
      self.nixosModules.yubikey
      self.nixosModules.tailscale
      self.nixosModules.twingate
      self.nixosModules.print
      self.nixosModules.qmk
      self.nixosModules.martin-user
      self.nixosModules.hypr-desktop
      self.nixosModules.whirl-home-manager
    ];

    networking.hostName = "whirl";
    networking.networkmanager.enable = true;

    services.upower.enable = true;

    # LUKS-encrypted swap partition (nvme0n1p3, not auto-detected by nixos-generate-config)
    boot.initrd.luks.devices."luks-c5ef7dea-9875-4d93-a0a4-b063c31d44e2".device = "/dev/disk/by-uuid/c5ef7dea-9875-4d93-a0a4-b063c31d44e2";

    environment.systemPackages = with pkgs; [
      brightnessctl
    ];
  };

  flake.nixosConfigurations.whirl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      self.nixosModules.whirl
      ./hardware-configuration.nix
    ];
  };
}

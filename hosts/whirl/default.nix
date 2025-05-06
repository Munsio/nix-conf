{ pkgs, hostname, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
  ];

  # All Hardware relevant stuff goes here.
  boot.initrd.luks.devices."luks-c5ef7dea-9875-4d93-a0a4-b063c31d44e2".device =
    "/dev/disk/by-uuid/c5ef7dea-9875-4d93-a0a4-b063c31d44e2";

  # Host-specific configuration for 'whirl'
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  # Enable NixOS modules using nixModules
  nixModules = {
    audio.enable = true;
    bluetooth.enable = true;
    systemd-boot.enable = true;

    # Enable bundles
    bundles.automount.enable = true;
    bundles.yubikey.enable = true;
  };

  # System-specific packages
  environment.systemPackages = with pkgs;
    [
      # Add host-specific packages here
    ];
}

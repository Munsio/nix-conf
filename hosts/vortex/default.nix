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
    networking.networkmanager.ensureProfiles.profiles.default-ethernet = {
      connection = {
        id = "default-ethernet";
        type = "ethernet";
        autoconnect = true;
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };

    services.greetd.settings.initial_session = {
      command = "Hyprland";
      user = "martin";
    };

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

  flake.packages.x86_64-linux.vortex-proxmox-image = (inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      self.nixosModules.vortex
      ({lib, modulesPath, ...}: {
        imports = [(modulesPath + "/virtualisation/proxmox-image.nix")];
        proxmox.qemuConf.name = "vortex";
        proxmox.qemuConf.bios = "ovmf";
        proxmox.qemuConf.cores = 24;
        proxmox.qemuConf.memory = 57344;
        proxmox.qemuConf.net0 = "virtio=BC:24:11:00:00:01,bridge=vmbr0,firewall=1,tag=100";
        virtualisation.diskSize = "auto";
        proxmox.cloudInit.enable = false;
        proxmox.qemuExtraConf.machine = "q35";
        proxmox.qemuExtraConf.cpu = "host";
        boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
      })
    ];
  }).config.system.build.VMA;
}

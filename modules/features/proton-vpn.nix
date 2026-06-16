{...}: {
  flake.nixosModules.proton-vpn = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.proton-vpn
    ];
  };
}

{...}: let
  tailscaleModule = {pkgs, ...}: {
    environment.systemPackages = [pkgs.tailscale];

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };
in {
  flake.nixosModules.tailscale = tailscaleModule;
  flake.darwinModules.tailscale = tailscaleModule;
}

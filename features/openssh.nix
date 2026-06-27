{...}: let
  opensshModule = {
    services.openssh = {
      enable = true;
      openFirewall = false;
    };
  };
in {
  flake.nixosModules.openssh = opensshModule;
  flake.darwinModules.openssh = opensshModule;
}

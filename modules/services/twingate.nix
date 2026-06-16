{...}: {
  flake.nixosModules.twingate = {
    services.twingate = {
      enable = true;
    };
  };
}

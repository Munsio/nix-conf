{...}: {
  flake.nixosModules.openssh = {
    services = {
      openssh = {
        enable = true;
        openFirewall = false;
      };
    };
  };
}

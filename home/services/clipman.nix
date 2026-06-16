{...}: {
  flake.homeModules.clipman = {
    services.clipman = {
      enable = true;
    };
  };
}

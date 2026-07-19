{...}: {
  flake.nixosModules.openbox = {...}: {
    services.xserver = {
      enable = true;
      windowManager.openbox.enable = true;
      displayManager.startx.enable = true;
    };
  };
}

{ ... }: {
  nixModules = {
    hyprland.enable = true;
    services.greetd.enable = true;
  };
}

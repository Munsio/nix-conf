{...}: {
  flake.homeModules.wayland-idle-inhibitor = {
    services.wayland-pipewire-idle-inhibit = {
      enable = true;
    };
  };
}

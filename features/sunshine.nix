{...}: {
  flake.nixosModules.sunshine = {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    # Pinned explicitly rather than relying on upstream's current default,
    # since that could change silently across nixpkgs updates.
    systemd.user.services.sunshine.serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}

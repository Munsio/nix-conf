{...}: {
  flake.nixosModules.sunshine = {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings.csrf_allowed_origins = "https://vortex.treml.group";
      settings.do_cmd = "";
    };
  };
}

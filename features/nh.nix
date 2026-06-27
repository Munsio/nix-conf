{...}: {
  flake.homeModules.nh = {config, ...}: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 5";
      };
      homeFlake = "${config.home.homeDirectory}/nix-conf";
    };
  };
}

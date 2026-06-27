{...}: {
  flake.homeModules.discord = {
    programs.discord = {
      enable = true;
    };
  };
}

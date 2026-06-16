{...}: {
  flake.homeModules.carapace = {
    programs.carapace = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}

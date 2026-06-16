{...}: {
  flake.homeModules.zoxide = {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };
  };
}

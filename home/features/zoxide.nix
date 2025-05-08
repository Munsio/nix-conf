{...}: {
  # Enable Zoxide directory jumper in home-manager
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = ["--cmd cd"];
  };
}

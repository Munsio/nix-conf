{...}: {
  # Enable Zoxide directory jumper in home-manager
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };
}

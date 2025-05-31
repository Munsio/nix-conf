{pkgs, ...}: {
  # Enable Discord in home-manager
  home.packages = with pkgs; [vesktop];

  home.shellAliases = {
    discord = "vesktop";
  };
}

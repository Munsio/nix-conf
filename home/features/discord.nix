{pkgs, ...}: {
  # Enable Discord in home-manager
  home.packages = with pkgs; [discord];
}

{pkgs, ...}: {
  # Add hyprpaper to home packages
  home.packages = with pkgs; [hyprpaper];
}

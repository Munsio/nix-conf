{pkgs, ...}: {
  # Enable Moonlight game streaming client in home-manager
  home.packages = with pkgs; [moonlight-qt];
}

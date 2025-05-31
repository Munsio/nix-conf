{pkgs, ...}: {
  # Enable Moonlight game streaming client in home-manager
  home.packages = [
    pkgs.moonlight-qt
  ];
}

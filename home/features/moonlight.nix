{pkgs, ...}: {
  # Enable Moonlight game streaming client in home-manager
  home.packages = [
    pkgs.unstable.moonlight-qt
  ];
}

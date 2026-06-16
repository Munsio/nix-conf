{...}: {
  flake.homeModules.moonlight = {pkgs, ...}: {
    home.packages = [
      pkgs.moonlight-qt
    ];
  };
}

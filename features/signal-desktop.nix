{...}: {
  flake.homeModules.signal-desktop = {pkgs, ...}: {
    home.packages = with pkgs; [
      signal-desktop
    ];
  };
}

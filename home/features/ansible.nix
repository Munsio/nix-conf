{...}: {
  flake.homeModules.ansible = {pkgs, ...}: {
    home.packages = with pkgs; [
      ansible
    ];
  };
}

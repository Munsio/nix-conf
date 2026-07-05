{...}: {
  flake.homeModules.opentofu = {pkgs, ...}: {
    home.packages = with pkgs; [
      opentofu
    ];
  };
}

{...}: {
  flake.homeModules.gnome-disks = {pkgs, ...}: {
    home.packages = [
      pkgs.gnome-disk-utility
    ];
  };
}

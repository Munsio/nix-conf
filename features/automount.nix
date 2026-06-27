{...}: {
  flake.nixosModules.automount = {pkgs, ...}: {
    services = {
      devmon.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
    };

    environment.systemPackages = with pkgs; [
      ntfs3g
      exfatprogs
      dosfstools
    ];
  };
}

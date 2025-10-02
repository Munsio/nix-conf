{
  pkgs,
  hostname,
  inputs,
  ...
}: {
  # Host-specific configuration for 'whirl'
  networking = {
    hostName = hostname;
  };

  # Enable NixOS modules using nixModules
  nixModules = {
    # Enable bundles
    bundles = {
      #hypr-desktop.enable = true;
    };
  };

  # System-specific packages
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
  ];
}

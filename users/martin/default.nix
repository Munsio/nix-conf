{...}: let
  username = "martin";
  directory = "/home/martin";
in {
  # User-specific configuration for 'martin'
  nixModules = {
    devenv.enable = true;
    services = {
      print.enable = true;
      twingate.enable = true;
    };
  };

  # Create the user account
  users.users.${username} = {
    isNormalUser = true;
    description = "Martin";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "camera"
      "networkmanager"
      "dialout"
      "adbusers"
    ];
  };

  # Userspecific overrides
  programs.nh.flake = "${directory}/nix-conf";
}

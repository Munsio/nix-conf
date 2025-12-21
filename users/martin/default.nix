{...}: let
  username = "martin";
  directory = "/home/martin";
in {
  # User-specific configuration for 'martin'
  nixModules = {
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

  security.pam = {
    u2f = {
      enable = true;
      settings = {
        authfile = "${directory}/.config/yubico/u2f_keys";
      };
    };
  };

  # Userspecific overrides
  programs.nh.flake = "${directory}/nix-conf";
}

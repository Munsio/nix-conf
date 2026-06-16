{...}: {
  flake.nixosModules.martin-user = {
    users.users.martin = {
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
          authfile = "/home/martin/.config/yubico/u2f_keys";
        };
      };
    };

    programs.nh.flake = "/home/martin/nix-conf";
  };
}

{...}: {
  flake.nixosModules.martin-user = {
    config,
    lib,
    ...
  }: let
    username = config.my.nixosUser.martin.username;
  in {
    options.my.nixosUser.martin.username = lib.mkOption {
      type = lib.types.str;
      default = "martin";
    };

    config = {
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
            authfile = "/home/${username}/.config/yubico/u2f_keys";
          };
        };
      };
    };
  };

  flake.darwinModules.martin-user = {
    config,
    lib,
    ...
  }: let
    username = config.my.darwinUser.martin.username;
  in {
    options.my.darwinUser.martin.username = lib.mkOption {
      type = lib.types.str;
      default = "martin";
    };

    config = {
      system.primaryUser = username;
      users.users.${username}.home = "/Users/${username}";
    };
  };
}

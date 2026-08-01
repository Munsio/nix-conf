{...}: {
  flake.nixosModules.sudo = {
    lib,
    config,
    ...
  }: {
    options.sudo.passwordlessSwitch = {
      enable = lib.mkEnableOption "passwordless nixos-rebuild switch for specific users";

      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["martin"];
        description = ''
          Users allowed to run `nixos-rebuild switch/test/boot` (and
          `switch-to-configuration` directly, e.g. via `--target-host`)
          without a sudo password.
        '';
      };
    };

    config = lib.mkIf config.sudo.passwordlessSwitch.enable {
      security.sudo.extraRules =
        map (user: {
          users = [user];
          commands =
            (map (action: {
                command = "/nix/store/*/bin/switch-to-configuration ${action}";
                options = ["NOPASSWD"];
              })
              ["switch" "test" "boot"])
            ++ [
              # nixos-rebuild --target-host wraps several of its remote steps
              # (updating the system profile symlink, running
              # switch-to-configuration via systemd-run, ...) in a
              # `/bin/sh -c '...'` shim whose exact contents differ by phase
              # and version. Rather than chasing each exact wrapped command,
              # this covers the whole invocation shape at once.
              {
                command = "/bin/sh -c *";
                options = ["NOPASSWD"];
              }
            ];
        })
        config.sudo.passwordlessSwitch.users;
    };
  };
}

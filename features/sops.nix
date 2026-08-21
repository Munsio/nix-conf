{inputs, ...}: {
  flake.nixosModules.sops = {config, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops = {
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/machine-key.txt";
        generateKey = true;
      };
      secrets = {
        "api-keys/nix-github.com" = {
          mode = "0440";
          owner = config.users.users.martin.name;
        };
      };
    };

    nix.extraOptions = ''
      !include ${config.sops.secrets."api-keys/nix-github.com".path}
    '';
  };

  flake.homeModules.sops = {
    pkgs,
    config,
    ...
  }: {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    home.packages = with pkgs; [
      sops
      age
      age-plugin-yubikey
    ];

    sops = {
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "${config.home.homeDirectory}/.config/sops/age/machine-key.txt";
        generateKey = true;
      };
    };
  };
}

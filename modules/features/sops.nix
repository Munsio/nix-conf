{inputs, ...}: {
  flake.nixosModules.sops = {config, ...}: {
    # TODO: investigate sops.secrets.<name>.neededForUsers = true
    # to ensure secrets are decrypted before the user session starts.
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops = {
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/machine-key.txt";
        generateKey = true;
      };
      secrets = {
        "api-keys/nix-github.com" = {};
      };
    };

    nix.extraOptions = ''
      !include ${config.sops.secrets."api-keys/nix-github.com".path}
    '';
  };
}

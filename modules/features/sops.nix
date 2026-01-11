{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # Sops config
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
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
}

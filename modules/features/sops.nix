{inputs, ...}: {
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
  };
}

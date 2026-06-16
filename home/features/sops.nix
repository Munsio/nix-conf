{inputs, ...}: {
  flake.homeModules.sops = {
    pkgs,
    config,
    ...
  }: {
    # TODO: investigate sops.secrets.<name>.neededForUsers = true
    # to ensure secrets are decrypted before the user session starts.
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];

    home.packages = with pkgs; [
      sops
      age
      age-plugin-yubikey
    ];

    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "${config.home.homeDirectory}/.config/sops/age/machine-key.txt";
        generateKey = true;
      };
    };
  };
}

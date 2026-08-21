{self, ...}: {
  flake.homeModules.martin-whirl = {
    config,
    lib,
    ...
  }: {
    imports = [
      self.homeModules.discord
      self.homeModules.localsend
      self.homeModules.moonlight
      self.homeModules.signal-desktop
      self.homeModules.ghostty
      self.homeModules.zen-browser
      self.homeModules.sops
    ];

    programs = {
      git = lib.mkIf config.programs.git.enable {
        settings.user.email = "git@treml.dev";
        settings.user.name = "Martin Treml";
      };
    };

    sops = {
      defaultSopsFile = "${self}/secrets/whirl.yaml";
      secrets = {
        "yubico/yubi5-nfc" = {
          path = "${config.home.homeDirectory}/.config/yubico/u2f_keys";
        };
        "ssh_keys/martin/private" = {
          path = "/home/martin/.ssh/id_ed25519";
        };
        "ssh_keys/martin/public" = {
          path = "/home/martin/.ssh/id_ed25519.pub";
        };
        "ssh_keys/codeberg/private" = {
          path = "/home/martin/.ssh/id_codeberg";
        };
        "ssh_keys/codeberg/public" = {
          path = "/home/martin/.ssh/id_codeberg.pub";
        };
      };
    };
  };
}

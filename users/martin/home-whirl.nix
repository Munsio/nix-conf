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

      fish = lib.mkIf config.programs.fish.enable {
        shellAliases = {
          # Build + remotely deploy vortex's NixOS config from whirl's
          # nix-conf checkout, mirroring the local os-update alias
          # (features/fish.nix) but targeting vortex over SSH.
          #
          # -e passwordless: nh's default ("auto") elevation strategy
          # prompts for a sudo password on the remote host even though
          # vortex's sudoers has a NOPASSWD rule for nixos-rebuild/
          # switch-to-configuration (see sudo.passwordlessSwitch in
          # features/sudo.nix). "passwordless" is nh's strategy built
          # specifically for that case (nix-community/nh#583).
          vortex-update = "nh os switch -H vortex --target-host martin@vortex.treml.group -e passwordless -u -a";
        };
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

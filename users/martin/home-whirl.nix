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
          # Plain nixos-rebuild, not `nh os switch`: nh always prompts for
          # a remote sudo password even with -e passwordless, because it
          # sets the system profile via a bare `sudo nix build --no-link
          # --profile ...` that isn't covered by vortex's sudoers NOPASSWD
          # rule (see sudo.passwordlessSwitch in features/sudo.nix) —
          # confirmed via `nh ... -v` debug output (nix-community/nh#583).
          # nixos-rebuild wraps its remote steps in `/bin/sh -c '...'`,
          # which that same NOPASSWD rule already covers, so it deploys
          # with no password prompt.
          vortex-update = "nixos-rebuild switch --flake ~/nix-conf#vortex --target-host martin@vortex.treml.group --sudo";
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
        "ssh_keys/gitea/private" = {
          path = "/home/martin/.ssh/id_gitea";
        };
        "ssh_keys/gitea/public" = {
          path = "/home/martin/.ssh/id_gitea.pub";
        };
      };
    };
  };
}

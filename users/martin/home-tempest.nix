{
  self,
  release,
  ...
}: {
  flake.darwinModules.martin-tempest = {
    my.darwinUser.martin.username = "martin.treml";
  };

  flake.homeModules.martin-tempest = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      self.homeModules.carapace
      self.homeModules.claude-code
      self.homeModules.devenv
      self.homeModules.direnv
      self.homeModules.fish
      self.homeModules.git
      self.homeModules.opencode
      self.homeModules.starship
      self.homeModules.zed
      self.homeModules.zoxide
      self.homeModules.nh
    ];

    programs = {
      home-manager.enable = true;
      nh.darwinFlake = "${config.home.homeDirectory}/nix-conf";
      fish.shellAliases.os-update = lib.mkForce "nh darwin switch -u";
      git.settings.user.email = "martin.treml@agilox.net";
    };

    home = {
      stateVersion = release;
      username = "martin.treml";
      homeDirectory = "/Users/martin.treml";
      sessionVariables = {
        TERMINAL = "kitty";
        EDITOR = "vim";
      };
      packages = with pkgs; [
        fzf
        jq
      ];
    };
  };
}

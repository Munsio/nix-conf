{self, ...}: {
  flake.homeModules.martin-darwin = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      self.homeModules.carapace
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
    };

    home = {
      stateVersion = "26.05";
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

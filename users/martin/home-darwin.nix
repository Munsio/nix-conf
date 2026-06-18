{self, ...}: {
  flake.homeModules.martin-darwin = {pkgs, ...}: {
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
    ];

    programs.home-manager.enable = true;

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

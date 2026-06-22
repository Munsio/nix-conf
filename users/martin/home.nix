{self, ...}: {
  flake.homeModules.martin = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.homeModules.ansible
      self.homeModules.devenv
      self.homeModules.direnv
      self.homeModules.fish
      self.homeModules.fuzzel
      self.homeModules.git
      self.homeModules.gnome-disks
      self.homeModules.carapace
      self.homeModules.kitty
      self.homeModules.nvf
      self.homeModules.obsidian
      self.homeModules.opencode
      self.homeModules.opentofu
      self.homeModules.starship
      self.homeModules.yazi
      self.homeModules.zed
      self.homeModules.zoxide
      self.homeModules.clipman
      self.homeModules.nh
    ];

    programs = {
      home-manager.enable = true;
      nh.osFlake = "${config.home.homeDirectory}/nix-conf";
    };

    home = {
      username = "martin";
      homeDirectory = "/home/martin";
      stateVersion = "26.05";

      sessionVariables = {
        TERMINAL = "kitty";
        EDITOR = "vim";
      };

      packages = with pkgs; [
        jq
        dnsutils
        vlc
        fzf
        ack
      ];
    };

    hyprland-terminal = "kitty";

    wayland.windowManager.hyprland.extraConfig = ''
      hl.config({
        input = {
          kb_layout = "us",
          kb_variant = "altgr-intl",
        },
      })
    '';
  };
}

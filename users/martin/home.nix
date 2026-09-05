{
  self,
  release,
  ...
}: {
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
      self.homeModules.claude-code
      self.homeModules.kitty
      self.homeModules.nvf
      self.homeModules.obsidian
      self.homeModules.opencode
      self.homeModules.opentofu
      self.homeModules.ssh
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
      stateVersion = release;

      sessionVariables = {
        TERMINAL =
          if config.programs.ghostty.enable
          then "ghostty"
          else "kitty";
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

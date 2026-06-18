{
  self,
  inputs,
  ...
}: {
  flake.darwinConfigurations.tempest = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {inherit inputs;};
    modules = [
      self.darwinModules.tempest-host
      self.darwinModules.tempest-home-manager
    ];
  };

  flake.darwinModules.tempest-host = {pkgs, ...}: {
    imports = [
      self.darwinModules.unstableOverlay
      self.darwinModules.nh
      self.darwinModules.martin-user
      self.darwinModules.martin-tempest
    ];

    nix.enable = false;
    nixpkgs.config.allowUnfree = true;

    security = {
      pam.services.sudo_local.touchIdAuth = true;
      sudo.extraConfig = ''
        Defaults timestamp_timeout=10
      '';
    };

    networking.hostName = "tempest";
    time.timeZone = "Europe/Vienna";

    environment.systemPackages = with pkgs; [
      fzf
      btop
      wget
      jq
    ];

    homebrew = {
      enable = true;
      casks = [
        "kitty"
        "zen"
      ];
    };

    system.defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        orientation = "bottom";
      };
      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
      };
    };

    system.stateVersion = 6;
  };
}

{
  lib,
  pkgs,
  hostVars,
  config,
  ...
}: let
  terminal = "ghostty";
in {
  # Home Manager configuration for martin

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Home directory configuration
  home = {
    # Use the username from the current user context
    username = "martin";
    # Use the homeDirectory from the current user context
    homeDirectory = "/home/martin";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    inherit (hostVars) stateVersion;

    sessionVariables = {
      TERMINAL = terminal;
      EDITOR = "vim";
    };

    # Packages installed to user profile
    packages = with pkgs; [jq dnsutils vlc];
  };

  homeModules = {
    direnv.enable = true;
    discord.enable = true;
    fish.enable = true;
    ghostty.enable = true;
    git.enable = true;
    helix.enable = true;
    moonlight.enable = true;
    nvf.enable = true;
    rustdesk.enable = true;
    services.flameshot.enable = true;
    signal-desktop.enable = true;
    starship.enable = true;
    vscode.enable = true;
    walker.enable = true;
    yazi.enable = true;
    zen-browser.enable = true;
    zoxide.enable = true;
  };

  # Custom configuration

  ## Custom Mime Apps
  xdg = {
    mimeApps = {
      enable = true;
      associations.added = {
        "application/pdf" = ["zen-twilight.desktop"];
      };
    };
  };

  ## Git
  programs = {
    git = lib.mkIf config.homeModules.git.enable {
      userEmail = "git@treml.dev";
      userName = "Martin Treml";
    };
  };

  ## Hyprland
  wayland.windowManager.hyprland.settings = {
    "$terminal" = terminal;

    # Keyboard
    input = {
      kb_layout = "at";
    };
  };
}

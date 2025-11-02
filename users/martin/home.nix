{
  pkgs,
  hostVars,
  hostname,
  ...
}: let
  terminal = "ghostty";
  hostModule = ./home-${hostname}.nix;
in {
  # Home Manager configuration for martin
  imports = [
    hostModule
  ];

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
    packages = with pkgs; [jq dnsutils vlc fzf];
  };

  homeModules = {
    ansible.enable = true;
    cline.enable = false;
    devenv.enable = true;
    direnv.enable = true;
    fish.enable = true;
    fuzzel.enable = true;
    git.enable = true;
    nvf.enable = true;
    helix.enable = true;
    obsidian.enable = true;
    opentofu.enable = true;
    starship.enable = true;
    vscode.enable = true;
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
        "application/json" = ["zen-twilight.desktop"];
        "application/pdf" = ["zen-twilight.desktop"];
        "application/x-extension-htm" = ["zen-twilight.desktop"];
        "application/x-extension-html" = ["zen-twilight.desktop"];
        "application/x-extension-shtml" = ["zen-twilight.desktop"];
        "application/x-extension-xht" = ["zen-twilight.desktop"];
        "application/x-extension-xhtml" = ["zen-twilight.desktop"];
        "application/xhtml+xml" = ["zen-twilight.desktop"];
        "text/html" = ["zen-twilight.desktop"];
        "text/plain" = ["zen-twilight.desktop"];
        "x-scheme-handler/about" = ["zen-twilight.desktop"];
        "x-scheme-handler/chrome" = ["zen-twilight.desktop"];
        "x-scheme-handler/http" = ["zen-twilight.desktop"];
        "x-scheme-handler/https" = ["zen-twilight.desktop"];
        "x-scheme-handler/mailto" = ["zen-twilight.desktop"];
        "x-scheme-handler/unknown" = ["zen-twilight.desktop"];
      };
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

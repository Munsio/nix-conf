{
  pkgs,
  hostVars,
  hostname,
  ...
}: let
  terminal = "kitty";
  hostModule = ./home-${hostname}.nix;
  username = "martin";
  homeDirectory = "/home/${username}";
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
    username = username;
    # Use the homeDirectory from the current user context
    homeDirectory = homeDirectory;

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
    packages = with pkgs; [
      jq
      dnsutils
      vlc
      fzf
      ack
    ];
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
    zed.enable = true;
    yazi.enable = true;
    zoxide.enable = true;
    kitty.enable = true;
    sops.enable = true;

    services = {
      clipman.enable = true;
    };
  };

  # Custom configuration

  ## Hyprland
  wayland.windowManager.hyprland.settings = {
    "$terminal" = terminal;

    # Keyboard
    input = {
      kb_layout = hostVars.keyboardLayout;
      kb_variant = hostVars.keyboardVariant;
    };
  };
}

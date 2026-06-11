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
    inherit username homeDirectory;

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
    devenv.enable = true;
    direnv.enable = true;
    fish.enable = true;
    fuzzel.enable = true;
    git.enable = true;
    gnome-disks.enable = true;
    helix.enable = true;
    hyprland.terminal = terminal;
    kitty.enable = true;
    nvf.enable = true;
    obsidian.enable = true;
    opencode.enable = true;
    opentofu.enable = true;
    sops.enable = true;
    starship.enable = true;
    yazi.enable = true;
    zed.enable = true;
    zoxide.enable = true;

    services = {
      clipman.enable = true;
    };
  };

  # Custom configuration

  ## Hyprland
  wayland.windowManager.hyprland.extraConfig = ''
    hl.config({
      input = {
        kb_layout = "${hostVars.keyboardLayout}",
        kb_variant = "${hostVars.keyboardVariant}",
      },
    })
  '';
}

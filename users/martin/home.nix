{ lib, pkgs, hostVars, ... }:
let terminal = "ghostty";
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
    stateVersion = hostVars.stateVersion;

    sessionVariables = {
      TERMINAL = terminal;
      EDITOR = "vim";
    };

    # Packages installed to user profile
    packages = with pkgs; [ jq dnsutils vlc ];
  };

  homeModules = { ghostty.enable = true; };

  # Custom configuration

  ## Hyprland
  wayland.windowManager.hyprland.settings = { "$terminal" = terminal; };
}

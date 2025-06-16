{pkgs, ...}: {
  # Enable Hyprland and related packages in the system
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
  };

  # Add Hyprland-related packages to the system
  environment.systemPackages = with pkgs; [
    hyprlock # Screen locker for Hyprland
    hypridle # Idle daemon for Hyprland
    hyprpaper # Wallpaper daemon for Hyprland
    wl-clipboard
    wlinhibit
  ];
}

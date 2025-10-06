{pkgs, ...}: {
  # Enable Hyprland and related packages in the system
  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
    xwayland.enable = true;
  };

  # Add Hyprland-related packages to the system
  environment.systemPackages = with pkgs; [
    unstable.hyprlock # Screen locker for Hyprland
    unstable.hypridle # Idle daemon for Hyprland
    unstable.hyprpaper # Wallpaper daemon for Hyprland
    wl-clipboard
    wlinhibit
  ];
}

{...}: {
  flake.nixosModules.hyprland = {pkgs, ...}: {
    programs.hyprland = {
      enable = true;
      package = pkgs.unstable.hyprland;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      unstable.hyprlock
      unstable.hypridle
      unstable.hyprpaper
      wl-clipboard
      wlinhibit
    ];
  };
}

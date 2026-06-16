{self, ...}: {
  flake.homeModules.hypr-desktop = {
    imports = [
      self.homeModules.hyprland
      self.homeModules.hyprlock
      self.homeModules.hyprpaper
      self.homeModules.hyprshot
      self.homeModules.noctalia
      self.homeModules.icons-cursors
      self.homeModules.stylix
      self.homeModules.hypridle
      self.homeModules.wayland-idle-inhibitor
    ];
  };
}

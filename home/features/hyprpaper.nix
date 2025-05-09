{
  pkgs,
  lib,
  config,
  ...
}: {
  # Add hyprpaper to home packages
  home.packages = with pkgs; [hyprpaper];

  # You can add default configuration files for hyprpaper here if needed
  # home.file.".config/hypr/hyprpaper.conf".text = '''';
  # Add hypridle to Hyprland's exec-once when hypridle is enabled
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    exec-once = lib.mkMerge [["hyprpaper"]];
  };
}

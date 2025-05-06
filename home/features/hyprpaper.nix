{ pkgs, ... }: {
  # Add hyprpaper to home packages
  home.packages = with pkgs; [ hyprpaper ];

  # You can add default configuration files for hyprpaper here if needed
  # home.file.".config/hypr/hyprpaper.conf".text = '''';
}

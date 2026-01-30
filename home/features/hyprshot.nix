{
  lib,
  config,
  ...
}: {
  programs.hyprshot = {
    enable = true;
    saveLocation = "$HOME/Pictures/Screenshots";
  };

  # Add a keybinding for the power menu to Hyprland if it's enabled
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = [
      "$mod ALT, P, exec, hyprshot -m region" # Screenshot Region
      "$mod ALT CTRL, P, exec, hyprshot -m output"
      "$mod ALT CTRL SHIFT, P, exec, hyprshot -m window"
    ];
  };
}

{
  lib,
  config,
  ...
}: {
  programs.walker = {
    enable = true;
    # Settings can be added here later if needed.
  };

  # Add a keybinding for walker to Hyprland if it's enabled
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = [
      "ALT, Space, exec, walker"
    ];
  };
}

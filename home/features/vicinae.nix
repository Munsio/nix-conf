{
  lib,
  config,
  ...
}: {
  services.vicinae = {
    enable = true;
    autoStart = true;
    settings = {
      closeOnFocusLoss = true;
      faviconService = "twenty";
      font = {
        size = 10;
      };
      keybinding = "default";
      popToRootOnClose = true;
      rootSearch = {
        searchFiles = false;
      };
      theme = {
        name = "one-dark.json";
      };
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
    };
  };

  # Add a keybinding for vicinae to Hyprland if it's enabled
  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = [
      "alt, space, exec, vicinae vicinae://toggle" # Standard menu
      "$mod, l, exec, loginctl lock-session" # Lock session
      "ctrl_alt, v, exec, vicinae vicinae://extensions/vicinae/clipboard/history" # Plasma style clipboard menu
    ];

    layerrule = [
      "blur, vicinae"
      "ignorealpha 0, vicinae"
    ];
  };
}

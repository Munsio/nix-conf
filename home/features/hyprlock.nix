{lib, ...}: {
  # Enable and configure hyprlock (screen locker)
  programs.hyprlock = {
    enable = true;

    # Default configuration can be added here
    settings = {
      auth = {
        fingerprint.enabled = true;
      };

      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      input-field.fail_color = lib.mkForce "rgb(e06666)";
    };
  };
}

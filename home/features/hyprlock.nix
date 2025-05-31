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
        grace = 0;
        hide_cursor = true;
      };

      input-field.fail_color = lib.mkForce "rgb(e06666)";
    };
  };
}

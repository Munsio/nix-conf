{lib, pkgs, ...}: {
  # Enable and configure hyprlock (screen locker)
  programs.hyprlock = {
    enable = true;
    package = null;

    # Default configuration can be added here
    settings = {
      auth = {
        fingerprint.enabled = true;
      };

      general = {
        hide_cursor = true;
      };

      input-field.fail_color = lib.mkForce "rgb(e06666)";
    };
  };
}

{lib, ...}: {
  # Enable and configure hyprlock (screen locker)
  programs.hyprlock = {
    enable = true;
    package = null;

    # Default configuration can be added here
    settings = {
      auth = {
        fingerprint = {
          enabled = true;
          ready_message = "Scan fingerprint to unlock";
          present_message = "Scanning...";
        };
      };

      general = {
        hide_cursor = true;
      };

      input-field = {
        fade_on_empty = false;
        fail_color = lib.mkForce "rgb(e06666)";
      };

      label = [
        {
          monitor = "";
          text = ''cmd[update:500] timeout 0.5 yubikey-touch-detector --no-socket --stdout 2>/dev/null | awk '{print ($0=="U2F_1"?"Waiting for Yubikey touch":""); exit}' '';
          #text = "Blub die mau";
          color = "rgba(200, 200, 200, 1.0)";
          halign = "center";
          valign = "center";
          position = "0, -80";
          shadow_passes = 5;
          shadow_size = 10;
        }
        {
          #CapsLock status
          monitor = "";
          text = ''cmd[update:500] awk '{print ($0?"Capslock on":""); exit}' /sys/class/leds/input*::capslock/brightness'';
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 25;
          position = "30, 70";
          halign = "left";
          valign = "bottom";
          shadow_passes = 5;
          shadow_size = 10;
        }
      ];
    };
  };
}

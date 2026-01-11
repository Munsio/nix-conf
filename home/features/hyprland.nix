{...}: {
  # Enable Hyprland in home-manager
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = ["--all"];
    };
    package = null;
    portalPackage = null;
    # You can add default configuration here if needed
    settings = {
      debug = {
        disable_logs = false;
      };

      # Variables
      "$mod" = "SUPER";

      # General
      general = {
        gaps_in = 10;
        gaps_out = 10;
      };
      # Decoration
      decoration = {rounding = 10;};
      # Dwindle
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      misc = {disable_hyprland_logo = true;};

      input = {
        touchpad = {
          natural_scroll = true;
        };
      };

      gestures = {
        workspace_swipe_touch = true;
      };

      gesture = [
        # Workspace switching with 3 fingers
        "3, horizontal, workspace"
      ];

      # Bindings
      bind =
        [
          # Program bindings
          "$mod, RETURN, exec, $terminal"

          # General window/behaviour binding
          "$mod, Q, killactive,"
          "$mod SHIFT, F, togglefloating, "
          "$mod, F, fullscreen,"
          "$mod, P, pseudo, # dwindle"
          "$mod, J, togglesplit, # dwindle"

          # Move focus with $mod + arrow keys
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Workspace special mods
          "$mod SHIFT, right, movetoworkspace, r+1"
          "$mod SHIFT, left, movetoworkspace, r-1"

          # Scroll through existing workspaces with $mod + scroll
          "$mod, mouse_down, workspace, r+1"
          "$mod, mouse_up, workspace, r-1"
          #"$mod CTRL, right, workspace, e+1 "
          #"$mod CTRL, left, workspace, e-1 "
          "$mod CTRL, right, workspace, m+1"
          "$mod CTRL, left, workspace, m-1"

          # Resize
          "$mod ALT, left, resizeactive, -20 0"
          "$mod ALT, right, resizeactive, 20 0"
          "$mod ALT, up, resizeactive, 0 -20"
          "$mod ALT, down, resizeactive, 0 20"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (x: let
              ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ])
            10)
        );

      # Media Keys
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause" # the stupid key is called play , but it toggles
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Volume Keys
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      # Mouse bindings
      bindm = ["$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow"];

      env = [
        "NIXOS_OZONE_WL,1" # Needed for electron apps like VSCode/Discord
        "QT_QPA_PLATFORM,wayland;xcb"
        "GDK_BACKEND,wayland,x11,*"
      ];

      windowrule = [
        "monitor 1, match:class com.moonlight_stream.Moonlight"
        "idle_inhibit fullscreen, match:class .*" # Prevent locking screen when an app is in fullscreen.
      ];
    };
  };
}

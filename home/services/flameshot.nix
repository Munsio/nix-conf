{
  lib,
  config,
  pkgs,
  ...
}: {
  services.flameshot = {
    enable = true;
    package = pkgs.flameshot.overrideAttrs (old: {
      cmakeFlags = old.cmakeFlags or [] ++ ["-DUSE_WAYLAND_GRIM=ON"];
    });
    settings = {
      General = {
        disabledTrayIcon = true;
        showStartupLaunchMessage = false;
      };
    };
  };

  home.packages = [
    pkgs.grim
  ];

  wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = [
      ",Print,exec, flameshot gui"
    ];

    windowrule = [
      "noanim, class:^(flameshot)$"
      "float, class:^(flameshot)$"
      "move 0 0, class:^(flameshot)$"
      "pin, class:^(flameshot)$"
      "monitor 1, class:^(flameshot)$"
    ];
  };
}

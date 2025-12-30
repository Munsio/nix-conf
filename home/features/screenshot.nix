{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    grim
    slurp
  ];

  wayland.windowManager.hyprland.settings = lib.mkIf (config.wayland.windowManager.hyprland.enable) {
    bind = [
      "$mod CTRL, p, exec, region=$(slurp) && [ -n \"$region\" ] && grim -g \"$region\" - | wl-copy && grim -g \"$region\" - > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png && notify-send \"Screenshot of the region taken\" -t 1000" # screenshot of a region
    ];
  };
}

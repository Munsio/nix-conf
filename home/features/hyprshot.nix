{...}: {
  flake.homeModules.hyprshot = {
    config,
    lib,
    ...
  }: {
    programs.hyprshot = {
      enable = true;
      saveLocation = "$HOME/Pictures/Screenshots";
    };

    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd("hyprshot -m region"))
      hl.bind("SUPER + ALT + CTRL + P", hl.dsp.exec_cmd("hyprshot -m output"))
      hl.bind("SUPER + ALT + CTRL + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m window"))
    '';
  };
}

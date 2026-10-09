{...}: {
  flake.homeModules.obsidian = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = [
      pkgs.obsidian
    ];

    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      hl.workspace_rule({ workspace = "special:obsidian", on_created_empty = "obsidian" })
      hl.window_rule({ match = { class = "obsidian" }, workspace = "special:obsidian" })
      hl.bind("SUPER + O", hl.dsp.workspace.toggle_special("obsidian"))
    '';
  };
}

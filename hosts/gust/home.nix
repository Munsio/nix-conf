{
  inputs,
  self,
  ...
}: {
  flake.homeModules.gust-home = {
    config,
    lib,
    ...
  }: {
    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      hl.monitor({ output = "desc:AOC U34G2G1 0x00001BA3", mode = "3440x1440@99.98", position = "0x0", scale = 1 })
      hl.monitor({ output = "desc:BOE 0x0BFB", mode = "1920x1200@60", position = "3440x220", scale = 1 })
    '';
  };

  flake.homeConfigurations.gust = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {inherit inputs;};
    modules = [
      self.homeModules.martin
      self.homeModules.martin-gust
      self.homeModules.gust-home
      self.homeModules.hypr-desktop
      inputs.stylix.homeModules.stylix
      inputs.nvf.homeManagerModules.nvf
      inputs.wayland-pipewire-idle-inhibit.homeModules.default
      inputs.zen-browser-flake.homeModules.twilight
    ];
  };
}

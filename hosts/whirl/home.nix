{
  self,
  inputs,
  ...
}: {
  flake.homeModules.whirl-home = {
    config,
    lib,
    ...
  }: {
    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable ''
      hl.monitor({ output = "desc:AOC U34G2G1 0x00001BA3", mode = "3440x1440@99.98", position = "0x0", scale = 1 })
      hl.monitor({ output = "desc:BOE NE135A1M-NY1", mode = "2880x1920@120.00", position = "3440x220", scale = 2 })
      hl.workspace_rule({ workspace = "1", monitor = "DP-3" })
      hl.on("hyprland.start", function()
        hl.exec_cmd("hyprctl dispatch workspace 1")
      end)
    '';
  };

  flake.nixosModules.whirl-home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = {inherit inputs;};
      users.martin = {
        imports = [
          self.homeModules.martin
          self.homeModules.martin-whirl
          self.homeModules.whirl-home
          self.homeModules.hypr-desktop
          inputs.stylix.homeModules.stylix
          inputs.nvf.homeManagerModules.nvf
          inputs.wayland-pipewire-idle-inhibit.homeModules.default
          inputs.zen-browser-flake.homeModules.twilight
        ];
      };
    };
  };
}

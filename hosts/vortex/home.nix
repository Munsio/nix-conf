{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.vortex-home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = {inherit inputs;};
      users.martin.imports = [
        self.homeModules.martin
        self.homeModules.martin-vortex
        self.homeModules.stylix
        self.homeModules.lutris
        self.homeModules.openbox
        self.homeModules.ghostty
        self.homeModules.vortex-display
        self.homeModules.zen-browser
        inputs.stylix.homeModules.stylix
        inputs.nvf.homeManagerModules.nvf
        inputs.zen-browser-flake.homeModules.twilight
      ];
    };
  };

  flake.homeModules.vortex-display = {pkgs, ...}: {
    # DP-1 is the virtual Sunshine display (EDID set in hosts/vortex/default.nix);
    # HDMI-2 is the real monitor for emergency local access.
    # pcmanfm --desktop draws desktop icons, which bare Openbox lacks.
    xdg.configFile."openbox/autostart" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        ${pkgs.xrandr}/bin/xrandr --output DP-1 --primary --mode 3440x1440 --rate 100 --output HDMI-2 --auto --right-of DP-1

        # This is a headless streaming box; the display must never DPMS-sleep.
        # Sunshine's KMS capture can't recover once that happens (breaks with
        # "Error: Couldn't import RGB Image: 00003009" / EGL_BAD_MATCH on
        # every subsequent frame until the service crashes) and upstream has
        # no automatic re-wake/reinit on client connect yet
        # (LizardByte/Sunshine discussion #439).
        ${pkgs.xset}/bin/xset -dpms
        ${pkgs.xset}/bin/xset s off

        ${pkgs.pcmanfm}/bin/pcmanfm --desktop &

        # Autostart Steam so it's already up and logged in by the time a
        # Sunshine/Moonlight session connects, instead of making the remote
        # client wait through Steam's own startup.
        ${pkgs.steam}/bin/steam &
      '';
    };

    # Reusing each package's own shipped .desktop file (correct Icon=
    # already set) rather than hand-authoring new ones.
    home.file = {
      "Desktop/steam.desktop".source = "${pkgs.steam}/share/applications/steam.desktop";
      "Desktop/heroic.desktop".source = "${pkgs.heroic}/share/applications/com.heroicgameslauncher.hgl.desktop";
      "Desktop/lutris.desktop".source = "${pkgs.lutris}/share/applications/net.lutris.Lutris.desktop";
      "Desktop/pcmanfm.desktop".source = "${pkgs.pcmanfm}/share/applications/pcmanfm.desktop";
    };

    # Launch desktop icons directly instead of showing the ambiguous
    # Execute/Open/Cancel dialog libfm defaults to.
    xdg.configFile."libfm/libfm.conf".text = ''
      [config]
      quick_exec=1
    '';
  };
}

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
    # Forced virtual DP-1 output (see hosts/vortex/default.nix for the
    # systemd unit that makes the connector report as connected) needs its
    # actual mode set once X starts; nothing plugs into DP-1 so this can't
    # come from EDID. HDMI-2 is the real, physically connected monitor (used
    # only for occasional emergency local access) and just keeps its
    # native/preferred mode.
    #
    # The modeline below is a proper CVT-RB v2 (reduced blanking) timing,
    # not plain CVT/GTF. Plain CVT for 3440x1440@100 needs a 728MHz pixel
    # clock, which turned out to be too demanding for the CRTC to reliably
    # commit (intermittent "Configure crtc 0 failed" / silent no-op, on top
    # of a REG_WAIT timeout in optc401 seen at every boot) - this left DP-1
    # stuck at its EDID-preferred 1920x1080 more often than not. CVT-RB v2
    # needs only 531.52MHz for the same resolution/refresh, comfortably
    # inside typical HDMI 2.0/DP 1.2 bandwidth, and has been reliable in
    # testing where the plain-CVT mode wasn't (confirmed on both DP-1 and,
    # experimentally, directly on HDMI-2 too - kept on DP-1 only since
    # HDMI-2 doesn't need to match the streaming resolution).
    #
    # pcmanfm --desktop also draws the desktop icons below, since bare
    # Openbox has no desktop/icon support of its own (same pairing LXDE used).
    xdg.configFile."openbox/autostart" = {
      executable = true;
      text = ''
        #!${pkgs.runtimeShell}
        ${pkgs.xrandr}/bin/xrandr \
          --newmode "3440x1440_100.00_rb2" 531.52 3440 3448 3480 3520 1440 1496 1504 1510 +hsync -vsync
        ${pkgs.xrandr}/bin/xrandr --addmode DP-1 "3440x1440_100.00_rb2"
        ${pkgs.xrandr}/bin/xrandr --output DP-1 --primary --mode "3440x1440_100.00_rb2" --output HDMI-2 --auto --right-of DP-1
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

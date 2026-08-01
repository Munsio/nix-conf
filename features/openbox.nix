{...}: {
  flake.nixosModules.openbox = {pkgs, ...}: {
    services.xserver = {
      enable = true;
      windowManager.openbox.enable = true;
      displayManager.startx = {
        enable = true;
        generateScript = true;
      };
    };

    # Openbox has no compositor-specific portal (that's mostly a Wayland
    # concern, e.g. xdg-desktop-portal-wlr) — xdg-desktop-portal-gtk is the
    # generic, WM-agnostic backend and works fine under plain X11.
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };
  };

  flake.homeModules.openbox = {
    pkgs,
    lib,
    config,
    ...
  }: let
    terminal = "${config.programs.ghostty.package}/bin/ghostty";
  in {
    xdg.configFile."openbox/rc.xml".text =
      lib.replaceStrings
      ["<chainQuitKey>C-g</chainQuitKey>"]
      [
        ''
          <chainQuitKey>C-g</chainQuitKey>

          <keybind key="W-Return">
            <action name="Execute">
              <command>${terminal}</command>
            </action>
          </keybind>
          <keybind key="W-Escape">
            <action name="ShowMenu">
              <menu>root-menu</menu>
            </action>
          </keybind>
        ''
      ]
      (builtins.readFile "${pkgs.openbox}/etc/xdg/openbox/rc.xml");

    xdg.configFile."openbox/menu.xml".text =
      lib.replaceStrings
      [
        ''<menu id="apps-term-menu" label="Terminals">''
        ''<item label="Log Out">''
      ]
      [
        ''
          <menu id="apps-term-menu" label="Terminals">
            <item label="Ghostty">
              <action name="Execute">
                <command>${terminal}</command>
              </action>
            </item>
        ''
        ''
          <item label="Reboot">
            <action name="Execute">
              <command>systemctl reboot</command>
            </action>
          </item>
          <item label="Shutdown">
            <action name="Execute">
              <command>systemctl poweroff</command>
            </action>
          </item>
          <item label="Log Out">
        ''
      ]
      (builtins.readFile "${pkgs.openbox}/etc/xdg/openbox/menu.xml");
  };
}

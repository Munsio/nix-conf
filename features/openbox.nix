{...}: {
  flake.nixosModules.openbox = {pkgs, ...}: {
    services.xserver = {
      enable = true;
      windowManager.openbox.enable = true;
      displayManager.startx.enable = true;
    };

    # Openbox has no compositor-specific portal (that's mostly a Wayland
    # concern, e.g. xdg-desktop-portal-wlr) — xdg-desktop-portal-gtk is the
    # generic, WM-agnostic backend and works fine under plain X11.
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };
  };
}

{...}: {
  flake.homeModules.moonlight = {pkgs, ...}: {
    home.packages = [
      # Nix store mtimes never change, so Qt reuses stale qmlcache across updates and hangs at "Starting Desktop" (moonlight-qt#2029)
      (pkgs.moonlight-qt.overrideAttrs (old: {
        qtWrapperArgs = (old.qtWrapperArgs or []) ++ ["--set QML_DISABLE_DISK_CACHE 1"];
      }))
    ];
  };
}

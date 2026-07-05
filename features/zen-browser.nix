{...}: {
  flake.homeModules.zen-browser = {pkgs, ...}: {
    xdg.mimeApps.defaultApplications."application/pdf" = ["zen-beta.desktop"];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
      policies = {
        DisableTelemetry = true;
        DisableAppUpdate = true;
      };
      nativeMessagingHosts = [pkgs.firefoxpwa];
    };
  };
}

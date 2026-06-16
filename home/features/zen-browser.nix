{...}: {
  flake.homeModules.zen-browser = {pkgs, ...}: {
    programs.zen-browser = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        DisableAppUpdate = true;
      };
      nativeMessagingHosts = [pkgs.firefoxpwa];
    };
  };
}

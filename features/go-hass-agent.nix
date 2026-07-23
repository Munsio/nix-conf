{...}: {
  flake.nixosModules.go-hass-agent = {pkgs, ...}: {
    environment.systemPackages = [pkgs.go-hass-agent];

    systemd.user.services.go-hass-agent = {
      description = "Home Assistant agent";
      wantedBy = ["default.target"];
      after = ["network-online.target"];
      serviceConfig = {
        ExecStart = "${pkgs.go-hass-agent}/bin/go-hass-agent run";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}

{...}: {
  flake.nixosModules.go-hass-agent = {pkgs, ...}: {
    environment.systemPackages = [pkgs.go-hass-agent];

    systemd.user.services.go-hass-agent = {
      description = "Home Assistant agent";
      wantedBy = ["default.target"];
      wants = ["network-online.target"];
      after = ["network-online.target"];
      serviceConfig = {
        ExecStart = "${pkgs.go-hass-agent}/bin/go-hass-agent run";
        # go-hass-agent exits 0 even when it fails to start (e.g. HA
        # unreachable at boot before DNS is up), so Restart=on-failure
        # never triggers — it has to restart unconditionally.
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}

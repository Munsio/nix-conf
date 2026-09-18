{...}: {
  flake.homeModules.ssh = {
    programs.ssh = {
      enable = true;
      # Drop-in files (per-host, per-tool, etc.) live in config.d and are
      # loaded before any catch-all Host block, so they take precedence.
      includes = ["~/.ssh/config.d/*"];

      # enableDefaultConfig is going away upstream; these are exactly the
      # defaults it used to inject, kept explicit to preserve behavior.
      enableDefaultConfig = false;
      settings."*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };

    home.file.".ssh/config.d/.keep".text = "";
  };
}

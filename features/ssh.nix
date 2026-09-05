{...}: {
  flake.homeModules.ssh = {
    programs.ssh = {
      enable = true;
      # Drop-in files (per-host, per-tool, etc.) live in config.d and are
      # loaded before any catch-all Host block, so they take precedence.
      includes = ["~/.ssh/config.d/*"];
    };

    home.file.".ssh/config.d/.keep".text = "";
  };
}

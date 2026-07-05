{...}: {
  flake.homeModules.quickshell = {
    programs.quickshell = {
      enable = true;
      activeConfig = "default";
    };
  };
}

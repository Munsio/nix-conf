{...}: {
  programs.quickshell = {
    enable = true;
    #configs = {
    #  default = ./Quickshell;
    #};
    activeConfig = "default";
  };

  #home.file.".config/quickshell/default" = {
  #  source = ./Quickshell;
  #};
}

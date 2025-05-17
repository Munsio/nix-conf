# This file is intended to be imported conditionally
# based on config.homeModules.nvf.enable.
{ pkgs, lib, config, ... }:

{
  programs.nvf = {
    enable = true;        # Enable the nvf program configuration
    enableManpages = true; # Recommended by nvf documentation

    # User-specific configurations for nvf (like custom settings, plugins)
    # should be placed in the user's home.nix file (e.g., users/martin/home.nix)
    # directly under a `programs.nvf = { ... };` block.
    # This feature module primarily ensures nvf is activated when the
    # homeModules.nvf switch is on.
  };
}

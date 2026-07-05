{inputs, ...}: {
  flake.homeModules.opencode = {pkgs, ...}: {
    programs.opencode = {
      enable = true;
      package = inputs.opencode-src.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };
}

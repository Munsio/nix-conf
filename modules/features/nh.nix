{...}: let
  nhModule = {
    programs.nh = {
      enable = true;
      clean.extraArgs = "--keep-since 4d --keep 5";
    };
  };
in {
  flake.nixosModules.nh = nhModule;
  flake.darwinModules.nh = nhModule;
}

{
  config,
  lib,
  inputs,
  ...
}: let
  myLib = import ../lib/default.nix {inherit inputs lib;};
  cfg = config.nixModules;

  # Taking all modules in ./features and adding enables to them
  features = myLib.extendModules (name: {
    extraOptions = {
      nixModules.${name}.enable =
        lib.mkEnableOption "enable ${name} configuration";
    };

    configExtension = config: (lib.mkIf cfg.${name}.enable config);
  }) (myLib.filesIn ./features);

  # Taking all module bundles in ./bundles and adding bundle.enables to them
  bundles = myLib.extendModules (name: {
    extraOptions = {
      nixModules.bundles.${name}.enable =
        lib.mkEnableOption "enable ${name} module bundle";
    };

    configExtension = config: (lib.mkIf cfg.bundles.${name}.enable config);
  }) (myLib.filesIn ./bundles);

  # Taking all module services in ./services and adding services.enables to them
  services = myLib.extendModules (name: {
    extraOptions = {
      nixModules.services.${name}.enable =
        lib.mkEnableOption "enable ${name} service";
    };

    configExtension = config: (lib.mkIf cfg.services.${name}.enable config);
  }) (myLib.filesIn ./services);
in {
  imports = features ++ bundles ++ services;

  options.nixModules = {
    bundles = lib.mkOption {
      type = lib.types.submodule {options = {};};
      default = {};
      description = "Bundles to enable";
    };

    services = lib.mkOption {
      type = lib.types.submodule {options = {};};
      default = {};
      description = "Services to enable";
    };
  };
}

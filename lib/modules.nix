{ inputs, lib, pkgs, ... }:

let
  # Define module types
  moduleTypes = {
    nix = "nixModules";
    home = "homeModules";
  };

  # Function to import all Nix files from a directory
  importDir = dir:
    let
      # Return empty set if directory doesn't exist
      dirExists = builtins.pathExists dir;
      entries = if !dirExists then { } else builtins.readDir dir;

      # Filter for Nix files and directories
      nixFiles = lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".nix" name) entries;
      dirs = lib.filterAttrs (_: type: type == "directory") entries;

      # Import Nix files with proper argument handling
      modules = lib.mapAttrs' (name: _:
        let
          moduleName = lib.removeSuffix ".nix" name;
          imported = import (dir + "/${name}");
          # Simplified function argument handling
          module = if !builtins.isFunction imported then
            imported
          else if builtins.functionArgs imported == { } then
            imported { }
          else
            imported { inherit inputs lib pkgs; };
        in lib.nameValuePair moduleName module) nixFiles;

      # Recursively import directories
      nestedModules = lib.mapAttrs' (name: _:
        let subdir = dir + "/${name}";
        in lib.nameValuePair name (importDir subdir)) dirs;
    in modules // nestedModules;

  # Function to create a module with enable option
  mkModule =
    { name, description, module, type ? moduleTypes.nix, category ? null }:
    { config, lib, ... }: {
      options = let
        enableOption = lib.mkOption {
          type = lib.types.bool;
          default = false;
          inherit description;
        };
      in if category != null then {
        ${type}.${category}.${name}.enable = enableOption;
      } else {
        ${type}.${name}.enable = enableOption;
      };

      config = let
        isEnabled = if category != null then
          config.${type}.${category}.${name}.enable
        else
          config.${type}.${name}.enable;
      in lib.mkIf isEnabled module;
    };

  # Function to create modules from a directory
  mkModulesFromDir =
    { dir, description, type ? moduleTypes.nix, category ? null }:
    let
      # Import modules only if directory exists
      modules = importDir dir;

      # Convert each module to a proper module with enable option
      modulesList = lib.mapAttrsToList (name: module:
        mkModule { inherit name description module type category; }) modules;
    in modulesList;
in {
  inherit moduleTypes;

  # Function to create a module system (nixModules or homeModules)
  mkModuleSystem =
    { featuresDir, bundlesDir, servicesDir, type ? moduleTypes.nix }:
    let
      # Import modules from each directory
      featureModules = mkModulesFromDir {
        dir = featuresDir;
        description = "Enable this feature";
        inherit type;
        category = null; # Features are at the root level
      };

      bundleModules = mkModulesFromDir {
        dir = bundlesDir;
        description = "Enable this bundle";
        inherit type;
        category = "bundles";
      };

      serviceModules = mkModulesFromDir {
        dir = servicesDir;
        description = "Enable this service";
        inherit type;
        category = "services";
      };
      # Base module that sets up the module options
    in { lib, ... }: {
      options.${type} = {
        features = lib.mkOption {
          type = lib.types.attrsOf lib.types.bool;
          default = { };
          description = "Features to enable";
        };

        bundles = lib.mkOption {
          type = lib.types.submodule { options = { }; };
          default = { };
          description = "Bundles to enable";
        };

        services = lib.mkOption {
          type = lib.types.submodule { options = { }; };
          default = { };
          description = "Services to enable";
        };
      };

      # Import all modules
      imports = featureModules ++ bundleModules ++ serviceModules;
    };
}

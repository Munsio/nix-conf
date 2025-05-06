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
      # Check if directory exists
      dirExists = builtins.pathExists dir;

      # Get all entries in the directory if it exists, otherwise empty set
      entries = if dirExists then builtins.readDir dir else { };

      # Filter out non-Nix files and directories
      nixFiles = lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".nix" name) entries;

      # Filter directories
      dirs = lib.filterAttrs (_: type: type == "directory") entries;

      # Import each Nix file if there are any
      modules = if nixFiles == { } then
        { }
      else
        lib.mapAttrs' (name: _:
          let
            # Remove .nix extension
            moduleName = lib.removeSuffix ".nix" name;
            # Import the module
            imported = import (dir + "/${name}");
            # Check if the function expects arguments
            module = if builtins.isFunction imported then
            # Check the number of arguments the function expects
              if builtins.functionArgs imported == { } then
              # If it expects no arguments, call it with an empty set
                imported { }
              else
              # Otherwise, call it with lib and pkgs
                imported { inherit inputs lib pkgs; }
            else
              imported;
          in lib.nameValuePair moduleName module) nixFiles;

      # Recursively import directories if there are any
      nestedModules = if dirs == { } then
        { }
      else
        lib.mapAttrs' (name: _:
          let
            subdir = dir + "/${name}";
            subdirExists = builtins.pathExists subdir;
          in lib.nameValuePair name
          (if subdirExists then importDir subdir else { })) dirs;
      # Merge modules and nested modules
    in modules // nestedModules;

  # Function to create a module with enable option
  mkModule =
    { name, description, module, type ? moduleTypes.nix, category ? null }:
    { config, lib, ... }: {
      options = if category != null then {
        ${type}.${category}.${name} = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            inherit description;
          };
        };
      } else {
        ${type}.${name} = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            inherit description;
          };
        };
      };

      config = if category != null then
        lib.mkIf config.${type}.${category}.${name}.enable module
      else
        lib.mkIf config.${type}.${name}.enable module;
    };

  # Function to create modules from a directory
  mkModulesFromDir =
    { dir, description, type ? moduleTypes.nix, category ? null }:
    let
      # Check if directory exists
      dirExists = builtins.pathExists dir;

      # Import modules only if directory exists
      modules = if dirExists then importDir dir else { };

      # Convert each module to a proper module with enable option
      modulesList = if modules == { } then
        [ ]
      else
        lib.mapAttrsToList (name: module:
          mkModule {
            inherit name;
            inherit description;
            inherit module;
            inherit type;
            inherit category;
          }) modules;
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

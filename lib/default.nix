{
  inputs,
  lib,
  ...
}: let
  self = rec {
    # Helper functions for working with files and directories
    filesIn = dir: (map (fname: dir + "/${fname}")
      (builtins.attrNames (builtins.readDir dir)));

    dirsIn = dir:
      lib.filterAttrs (_: value: value == "directory") (builtins.readDir dir);

    fileNameOf = path: (builtins.head (builtins.split "\\." (baseNameOf path)));

    # Function to extend modules with enable options
    extendModule = {path, ...} @ args:
    # deadnix: skip
    {pkgs, ...} @ margs: let
      eval =
        if (builtins.isString path) || (builtins.isPath path)
        then import path margs
        else path margs;
      evalNoImports = builtins.removeAttrs eval ["imports" "options"];

      extra =
        if
          (builtins.hasAttr "extraOptions" args)
          || (builtins.hasAttr "extraConfig" args)
        then [
          ({...}: {
            options = args.extraOptions or {};
            config = args.extraConfig or {};
          })
        ]
        else [];
    in {
      imports = (eval.imports or []) ++ extra;

      options =
        if builtins.hasAttr "optionsExtension" args
        then (args.optionsExtension (eval.options or {}))
        else (eval.options or {});

      config =
        if builtins.hasAttr "configExtension" args
        then (args.configExtension (eval.config or evalNoImports))
        else (eval.config or evalNoImports);
    };

    # Apply extendModule to multiple modules
    extendModules = extension: modules:
      map (f: let
        name = fileNameOf f;
      in
        extendModule ((extension name) // {path = f;}))
      modules;

    # Function to create a HomeManager configuration
    mkHome = {
      hostname,
      user,
      system ? "x86_64-linux",
      extraHomeManagerModules ? [],
      overlays ? [],
    }: let
      # Import host variables (mandatory)
      hostVars = import ../hosts/${hostname}/variables.nix;

      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs hostname hostVars system;};
        modules =
          [
            # Apply overlays
            {
              nixpkgs.overlays = overlays;
            }
            ../home
            # Host-specific configuration
            ../hosts/${hostname}/home.nix

            # The Specific user
            ../users/${user}/home.nix
          ]
          ++ extraHomeManagerModules;
      };

    # Function to create a NixOS system configuration
    mkSystem = {
      hostname,
      system ? "x86_64-linux",
      users ? [],
      extraModules ? [],
      extraHomeManagerModules ? [],
      overlays ? [],
    }: let
      # Import host variables (mandatory)
      hostVars = import ../hosts/${hostname}/variables.nix;

      # Generate user modules
      userModules =
        lib.attrValues
        (lib.genAttrs users (user: ../users/${user}/default.nix));

      # Home Manager configuration
      homeManagerModule = inputs.home-manager.nixosModules.home-manager;

      # Home Manager configuration with sensible defaults
      defaultHomeManagerConfig = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          extraSpecialArgs = {inherit inputs hostname hostVars;};
          sharedModules = [../home];
          # Load user-specific home-manager configurations
          users = lib.genAttrs users (user: {
            imports =
              [../hosts/${hostname}/home.nix ../users/${user}/home.nix]
              ++ extraHomeManagerModules;
          });
        };
      };
    in
      lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs hostname hostVars;};
        modules =
          [
            # NixOS Module system
            ../modules

            # Apply overlays
            {
              nixpkgs.overlays = overlays;
            }

            # Base configuration for all hosts
            ../hosts/default.nix

            # Host-specific configuration
            ../hosts/${hostname}/default.nix

            # Home Manager configuration
            homeManagerModule
            defaultHomeManagerConfig
          ]
          # Add user modules and extra modules
          ++ userModules
          ++ extraModules;
      };

    # Function to create a system for all supported systems
    forAllSystems = pkgs:
      lib.genAttrs ["x86_64-linux" "aarch64-linux"]
      (system: pkgs inputs.nixpkgs.legacyPackages.${system});
  };
in
  self

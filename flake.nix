{
  description = "NixOS configuration with flakes and home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser-flake = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs"; # Assuming it might need nixpkgs
    };
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    # Available systems
    supportedSystems = ["x86_64-linux" "aarch64-linux"];

    # Function to generate attributes for each supported system
    forAllSystems = lib.genAttrs supportedSystems;

    # Import the library functions
    myLib = import ./lib/default.nix {inherit lib inputs;};
  in
    with myLib; {
      # NixOS configurations for different hosts
      nixosConfigurations = {
        # Whirl host configuration using mkSystem
        whirl = mkSystem {
          hostname = "whirl";
          users = ["martin"];
          extraHomeManagerModules = [
            inputs.zen-browser-flake.homeModules.twilight
            inputs.hyprpanel.homeManagerModules.hyprpanel
          ];
          overlays = [
            inputs.hyprpanel.overlay
            inputs.nix-vscode-extensions.overlays.default
          ];
        };
      };

      # Development shell for working with this flake
      devShells = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Nix language server
            nil

            # Nix formatting and linting tools
            alejandra # Formatter
            statix # Linter for suggestions
            deadnix # Find unused code
            # nix-linter is currently marked as broken in nixpkgs
          ];
        };
      });
    };
}

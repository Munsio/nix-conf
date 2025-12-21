{
  description = "NixOS configuration with flakes and home-manager";

  nixConfig = {
    extra-substituters = [
    ];
    extra-trusted-public-keys = [
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser-flake = {
      url = "github:0xc000022070/zen-browser-flake";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    wayland-pipewire-idle-inhibit.url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    # Available systems
    supportedSystems = ["x86_64-linux" "aarch64-linux"];

    # Function to generate attributes for each supported system
    forAllSystems = lib.genAttrs supportedSystems;

    # Import the library functions
    myLib = import ./lib/default.nix {inherit lib inputs;};

    myOverlays = import ./overlays {inherit inputs;};
  in
    with myLib; {
      # NixOS configurations for different hosts
      nixosConfigurations = {
        # Whirl host configuration using mkSystem
        whirl = mkSystem {
          hostname = "whirl";
          users = ["martin"];
          extraModules = [
            inputs.stylix.nixosModules.stylix
          ];
          extraHomeManagerModules = [
            inputs.stylix.homeModules.stylix
            inputs.nvf.homeManagerModules.nvf
            inputs.wayland-pipewire-idle-inhibit.homeModules.default
            inputs.zen-browser-flake.homeModules.twilight
          ];
          overlays = [
            myOverlays.unstable-packages
            inputs.nix-vscode-extensions.overlays.default
          ];
        };
      };

      homeConfigurations = {
        gust = mkHome {
          hostname = "gust";
          user = "martin";
          extraHomeManagerModules = [
            inputs.stylix.homeModules.stylix
            inputs.nvf.homeManagerModules.nvf
            inputs.wayland-pipewire-idle-inhibit.homeModules.default
            inputs.zen-browser-flake.homeModules.twilight
          ];

          overlays = [
            myOverlays.unstable-packages
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

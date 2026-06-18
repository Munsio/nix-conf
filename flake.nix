{
  description = "NixOS configuration with flakes and home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser-flake = {
      url = "github:0xc000022070/zen-browser-flake";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    wayland-pipewire-idle-inhibit.url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-src = {
      url = "github:anomalyco/opencode";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;
    inherit (lib.fileset) toList fileFilter;

    isNixModule = file:
      file.hasExt "nix"
      && file.name != "flake.nix"
      && file.name != "hardware-configuration.nix"
      && !lib.hasPrefix "_" file.name;

    importTree = dir:
      toList (fileFilter isNixModule dir);
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports =
        (importTree ./modules)
        ++ (importTree ./home)
        ++ (importTree ./hosts)
        ++ (importTree ./users);
    };
}

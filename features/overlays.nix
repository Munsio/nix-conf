{inputs, ...}: let
  unstableOverlay = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  unstableOverlayModule = {
    nixpkgs.overlays = [unstableOverlay];
  };
in {
  flake = {
    nixosModules.unstableOverlay = unstableOverlayModule;
    darwinModules.unstableOverlay = unstableOverlayModule;
    overlays.unstable = unstableOverlay;
  };
}

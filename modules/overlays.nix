{inputs, ...}: let
  opencode-overlay = _final: prev: {
    opencode = prev.opencode.overrideAttrs (oldAttrs: {
      version = "1.17.3";
      src = inputs.opencode-src;
      node_modules = oldAttrs.node_modules.overrideAttrs (_nmOld: {
        src = inputs.opencode-src;
        version = "1.17.3";
        outputHash = "sha256-V9LtFMyZj/rYXZ2R+ALbAL5yCZF58DZdCRg2KqdGVqs=";
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
      });
    });
  };
in {
  flake.nixosModules.unstableOverlay = {
    nixpkgs.overlays = [
      (final: _prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.stdenv.hostPlatform.system;
          config.allowUnfree = true;
          overlays = [opencode-overlay];
        };
      })
    ];
  };
}

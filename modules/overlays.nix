{inputs, ...}: let
  opencodeVersion = "1.17.13";
  opencodeHash = "sha256-9MgVcCt8PGRbtLr9pfmFS3F3rw+P0o7NX5ovibsz4WA=";
  opencode-overlay = _final: prev: {
    opencode = prev.opencode.overrideAttrs (oldAttrs: {
      version = opencodeVersion;
      src = inputs.opencode-src;
      node_modules = oldAttrs.node_modules.overrideAttrs (_nmOld: {
        src = inputs.opencode-src;
        version = opencodeVersion;
        outputHash = opencodeHash;
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
      });
    });
  };

  unstableOverlay = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
      overlays = [opencode-overlay];
    };
  };

  unstableOverlayModule = {
    nixpkgs.overlays = [unstableOverlay];
  };
in {
  flake.nixosModules.unstableOverlay = unstableOverlayModule;
  flake.darwinModules.unstableOverlay = unstableOverlayModule;
}

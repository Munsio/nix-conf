{inputs, ...}: let
  opencodeVersion = "1.17.12";
  opencodeHash = "sha256-M1Wa6dqUYq/XWX1a2khKen45HZiVm6fMVkTCx4zlgm8=";
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

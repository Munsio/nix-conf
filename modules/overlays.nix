{inputs, ...}: let
  opencodeVersion = "1.17.3";
  opencodeHash = "sha256-V9LtFMyZj/rYXZ2R+ALbAL5yCZF58DZdCRg2KqdGVqs=";
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
in {
  flake.nixosModules.unstableOverlay = {
    nixpkgs.overlays = [unstableOverlay];
  };

  flake.darwinModules.unstableOverlay = {
    nixpkgs.overlays = [unstableOverlay];
  };
}

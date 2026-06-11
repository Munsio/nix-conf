{inputs, ...}: let
  opencodeVersion = "1.17.3";

  opencode-overlay = _self: super: {
    opencode = super.opencode.overrideAttrs (oldAttrs: {
      version = opencodeVersion;
      src = inputs.opencode-src;
      node_modules = oldAttrs.node_modules.overrideAttrs (_nmOld: {
        src = inputs.opencode-src;
        version = opencodeVersion;
        outputHash = "sha256-V9LtFMyZj/rYXZ2R+ALbAL5yCZF58DZdCRg2KqdGVqs=";
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
      });
    });
  };
in {
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
      overlays = [
        opencode-overlay
      ];
    };
  };
}

{inputs, ...}: {
  flake.homeModules.opencode = {pkgs, ...}: let
    opencodePkgs = inputs.opencode-src.packages.${pkgs.stdenv.hostPlatform.system};

    # opencode's own nix/hashes.json regularly drifts from what `bun install`
    # actually produces for us, breaking the node_modules fixed-output
    # derivation with a hash mismatch (a known, recurring upstream issue,
    # not specific to a given commit or nixpkgs pin - reproduced identically
    # across two different opencode-src revisions).
    #
    # To refresh this hash after a `nix flake lock --update-input
    # opencode-src`: temporarily set it to pkgs.lib.fakeHash, run a build,
    # and copy the "got:" hash nix reports back in here.
    fixedNodeModules = opencodePkgs.opencode.node_modules.override {
      hash = "sha256-Ppc2Kgb9D9xdkrNMyQgPS6rn/zU5zMqMKvAmrFCj1zQ=";
    };
  in {
    programs.opencode = {
      enable = true;
      package = opencodePkgs.default.override {node_modules = fixedNodeModules;};
    };
  };
}

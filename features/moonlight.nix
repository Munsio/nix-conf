{...}: {
  flake.homeModules.moonlight = {pkgs, ...}: {
    home.packages = [
      # 6.2.0 fixes washed-out colors with Sunshine's 8-bit full range (moonlight-qt#1667); drop once nixpkgs has it
      (pkgs.moonlight-qt.overrideAttrs (finalAttrs: _: {
        version = "6.2.0";
        src = pkgs.fetchFromGitHub {
          owner = "moonlight-stream";
          repo = "moonlight-qt";
          tag = "v${finalAttrs.version}";
          hash = "sha256-s6b3L51jCNuYJS0dvx2tkNvzNzrsSzzdSfTgM+IR1kg=";
          fetchSubmodules = true;
        };
        patches = [];
      }))
    ];
  };
}

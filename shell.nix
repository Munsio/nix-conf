# This file provides backward compatibility for older Nix versions
# that don't support flakes.
(import
  (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
    sha256 = "0m4kgfjjrmpcm9s9rczz5vdiqqcxb2vvzyyik7msr9hdvdxd02xf";
  })
  {src = ./.;})
.shellNix
.default

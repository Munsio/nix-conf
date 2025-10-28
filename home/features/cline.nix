{ config, pkgs, lib, ... }:

let
  # You could pin the version here if you want
  clineVersion = "latest";
  cline = pkgs.buildNpmPackage rec {
    pname = "cline";
    version = "1.0.1";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/cline/-/cline-${version}.tgz";
      sha256 = "/AnxwoXpdSRztO1Pa4Aq9LmWddCZ08tpKEsHLxLMBQg="; # replace with real hash after first build
    };

    # The package requires Node.js 20+ (recommend Node.js 22) :contentReference[oaicite:2]{index=2}
    buildInputs = [ pkgs.nodejs_22 ];

    # Optionally you can set npmDeps (if lock file) etc.
    # For simplicity we rely on the standard buildNpmPackage behaviour.

    meta = with lib; {
      description = "CLI for Cline.ai — interactive AI Agent tool";
      homepage = "https://docs.cline.bot/cline-cli/installation";
      license = licenses.mit;  # adjust if different
      #maintainers = with maintainers; [ yourNameHere ];
    };
  };
in
{
  #home.packages = (config.home.packages or []) ++ [ cline ];

  home.packages = with pkgs; [
      cline
  ];

  # You might also want to set up a shell alias or wrapper:
#  home.file.".local/bin/cline" = {
#    text = ''
#      #!/usr/bin/env bash
#      exec ${cline}/bin/cline "$@"
#    '';
#    executable = true;
#  };

  # If you want autocompletion or other config, you can add here.
}

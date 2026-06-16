{...}: {
  systems = ["x86_64-linux" "aarch64-linux"];

  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        nil
        alejandra
        statix
        deadnix
        nodejs
      ];
    };
  };
}

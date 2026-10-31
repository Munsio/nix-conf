{inputs, ...}: {
  flake.nixosModules.xremap = {...}: {
    imports = [inputs.xremap-flake.nixosModules.default];

    services.xremap = {
      enable = true;
      serviceMode = "user";
      userName = "martin";
      withHypr = true;
      watch = true;

      config.keymap = [
        {
          name = "macOS-style editing shortcuts from the Keychron (Mac mode)";
          device.only = [
            "Keychron Keychron K1 Max Keyboard"
            "Keychron  Keychron Link  Keyboard"
          ];
          # Ghostty binds super+c/v/a natively (features/ghostty.nix) and has no
          # cut/undo actions; stepping aside here lets those fire instead of
          # eating the raw Super combo before Ghostty sees it.
          application.not = ["com.mitchellh.ghostty"];
          remap = {
            "Super-c" = "C-c";
            "Super-v" = "C-v";
            "Super-x" = "C-x";
            "Super-z" = "C-z";
            "Super-a" = "C-a";
          };
        }
      ];
    };
  };
}

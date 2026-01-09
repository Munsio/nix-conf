{
  lib,
  pkgs,
  config,
  ...
}: let
  uiFontFamily = lib.attrByPath ["stylix" "fonts" "sansSerif" "name"] "DejaVu Sans" config;
in {
  programs.zed-editor = {
    enable = true;

    extraPackages = [
      pkgs.nil
      pkgs.nixd
      pkgs.alejandra
      pkgs."rust-analyzer"
      pkgs.gopls
    ];

    mutableUserSettings = true;

    extensions = [
      "nix"
      "toml"
      "dockerfile"
      "json"
      "opencode"
      "perplexity"
    ];

    userSettings = {
      auto_update = false;
      vim_mode = true;

      theme = {
        mode = "dark";
        dark = "One Dark";
        light = "One Light";
      };

      relative_line_numbers = "enabled";
      buffer_font_size = 14;
      ui_font_family = uiFontFamily;
      ui_font_size = 14;

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      languages = {
        Nix = {
          formatter = {
            external = {
              command = "alejandra";
              arguments = [
                "--quiet"
                "--"
              ];
            };
          };
        };
      };
    };
  };
}

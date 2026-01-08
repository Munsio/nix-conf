{
  lib,
  pkgs,
  config,
  ...
}: let
  monospaceFont =
    lib.attrByPath [
      "stylix"
      "fonts"
      "monospace"
      "name"
    ] "JetBrainsMono Nerd Font Mono"
    config;

  uiFontFamily = lib.attrByPath ["stylix" "fonts" "sansSerif" "name"] "DejaVu Sans" config;
in {
  programs.zed-editor = {
    enable = true;
    package = pkgs.unstable.zed-editor;

    extraPackages = [
      pkgs.nil
      pkgs.nixd
      pkgs.alejandra
      pkgs."rust-analyzer"
      pkgs.gopls
    ];

    #mutableUserSettings = false;

    extensions = [
      "nix"
      "toml"
      "dockerfile"
      "json"
      "opencode"
    ];

    userSettings = {
      auto_update = false;
      helix_mode = true;

      theme = {
        mode = "dark";
        dark = "One Dark";
        light = "One Light";
      };

      relative_line_numbers = "enabled";
      buffer_font_family = monospaceFont;
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

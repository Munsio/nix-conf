{
  pkgs,
  inputs,
  ...
}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # User settings
    profiles.default = {
      # Use extensions from nix-vscode-extensions flake
      extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        # Nix support
        jnoortheen.nix-ide # Nix language support
        arrterian.nix-env-selector # Nix environment selector

        # Theme and UI
        pkief.material-icon-theme # Material icon theme

        # Utilities
        esbenp.prettier-vscode # Code formatter
        streetsidesoftware.code-spell-checker # Spell checker

        # Add more extensions as needed
      ];

      userSettings = {
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
        "editor.fontSize" = 14;
        "editor.lineHeight" = 22;
        "editor.renderWhitespace" = "boundary";
        "editor.rulers" = [80 120];
        "editor.minimap.enabled" = false;
        "editor.formatOnSave" = true;
        "editor.tabSize" = 2;
        "editor.insertSpaces" = true;
        "editor.detectIndentation" = true;

        "workbench.editor.enablePreview" = false;
        "workbench.colorTheme" = "Default Dark+";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "none";

        "window.titleBarStyle" = "custom";

        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
        "terminal.integrated.fontSize" = 14;
        "terminal.integrated.defaultProfile.linux" = "bash";

        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;

        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;

        "telemetry.telemetryLevel" = "off";

        # Nix specific settings
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.formatterPath" = "alejandra";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {"command" = ["alejandra"];};
          };
        };
      };

      # Keybindings
      keybindings = [
        {
          key = "ctrl+shift+b";
          command = "workbench.action.tasks.build";
        }
        {
          key = "ctrl+shift+t";
          command = "workbench.action.terminal.toggleTerminal";
        }
      ];
    };
  };

  # Additional packages that enhance the VSCode experience
  home.packages = with pkgs; [
    # Language servers
    nil # Nix language server
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # HTML, CSS, JSON, ESLint

    # Formatters
    alejandra
    prettierd

    # Linters
    statix # Nix linter
    deadnix # Find unused code in Nix
  ];
}

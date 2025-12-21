{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    mutableExtensionsDir = false;

    # User settings
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      # Use extensions from nix-vscode-extensions flake
      extensions = with pkgs.vscode-marketplace; [
        # Theme and UI
        pkief.material-icon-theme # Material icon theme
        sainnhe.everforest

        # Utilities
        esbenp.prettier-vscode # Code formatter
        streetsidesoftware.code-spell-checker # Spell checker
        streetsidesoftware.code-spell-checker-british-english
        eamodio.gitlens # Git
        nefrob.vscode-just-syntax # Just file support
        editorconfig.editorconfig

        # DevOPS
        gitlab.gitlab-workflow
        redhat.ansible
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools

        # Languages
        bmewburn.vscode-intelephense-client # PHP
        neilbrayfield.php-docblocker # PHP Doc blocks
        jnoortheen.nix-ide # Nix language support
        theqtcompany.qt-qml

        # Dependencies
        ms-python.python # from Ansible
        ms-azuretools.vscode-containers # from Docker
        redhat.vscode-yaml # From Kubernetes

        # AI
        continue.continue
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

        "chat.agent.enabled" = false;
        "chat.commandCenter.enabled" = false;

        "workbench.editor.enablePreview" = false;
        "workbench.colorTheme" = "Default Dark+";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "none";
        "workbench.secondarySideBar.defaultVisibility" = "hidden";

        "everforest.darkContrast" = "hard";
        "everforest.darkWorkbench" = "material";
        "everforest.highContrast" = false;

        "window.titleBarStyle" = "custom";

        "gitlab.duoCodeSuggestions.enabled" = false;
        "gitlab.duoChat.enabled" = false;
        "gitlab.duoAgentPlatform.enabled" = false;

        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
        "terminal.integrated.fontSize" = 14;
        "terminal.integrated.defaultProfile.linux" = "bash";

        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;

        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;
        "git.openRepositoryInParentFolders" = "never";
        "gitlens.launchpad.indicator.enabled" = false;

        "telemetry.telemetryLevel" = "off";

        "ansible.lightspeed.enabled" = false;

        "intelephense.environment.phpVersion" = "7.4.0";

        "continue.telemetryEnabled" = false;
        "yaml.schemas" = {
          "file:///home/martin/.vscode/extensions/continue.continue/config-yaml-schema.json" = [
            ".continue/**/*.yaml"
          ];
        };

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

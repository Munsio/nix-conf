{pkgs, ...}: {
  programs.helix = {
    enable = true;

    # Default settings for Helix
    settings = {
      theme = "everforest_dark";

      editor = {
        mouse = true;
        cursorline = true;
        color-modes = true;
        bufferline = "always";

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        statusline = {
          left = ["mode" "spinner"];
          center = ["file-name"];
          right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
          separator = "│";
        };

        lsp = {
          display-messages = true;
        };
      };

      keys = {
        normal = {
          esc = ["collapse_selection" "keep_primary_selection"];
        };
      };
    };

    # Language-specific settings
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "${pkgs.alejandra}/bin/alejandra";
          };
          language-servers = ["nil"];
        }
        {
          name = "go";
          auto-format = true;
          language-servers = ["gopls"];
        }
      ];
    };
  };
}

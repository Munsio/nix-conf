# This file is intended to be imported conditionally
# based on config.homeModules.nvf.enable.
{
  pkgs,
  lib,
  ...
}: {
  programs.nvf = {
    enable = true; # Enable the nvf program configuration
    enableManpages = true; # Recommended by nvf documentation

    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        options = {
          shiftwidth = 2;
          tabstop = 2;
          number = true;
        };

        spellcheck = {
          enable = true;
          programmingWordlist.enable = true;
        };

        binds.whichKey.enable = true;

        autopairs.nvim-autopairs.enable = true;

        comments.comment-nvim.enable = true;

        assistant.avante-nvim = {
          enable = true;

          setupOpts = {
            provider = "openrouter";
            providers = {
              openrouter = {
                __inherited_from = "openai";
                api_key_name = "OPENROUTER_API_KEY";
                endpoint = "https://openrouter.ai/api/v1";
                model = "google/gemini-2.5-pro-preview";
              };
            };
          };
        };

        filetree.neo-tree.enable = true;
        telescope.enable = true;
        statusline.lualine.enable = true;
        autocomplete.nvim-cmp.enable = true;

        theme = {
          enable = true;
          name = "onedark";
          style = "dark";
        };

        keymaps = [
          {
            key = "<C-b>";
            mode = "n";
            silent = true;
            action = ":Neotree filesystem left<CR>";
          }
          {
            key = "<C-a>";
            mode = "n";
            silent = true;
            action = ":CodeCompanionActions<CR>";
          }
        ];

        lsp = {
          enable = true;
          formatOnSave = true;
        };

        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };

        dashboard.alpha.enable = true;

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix = {
            enable = true;
            lsp.package = pkgs.nil;
          };

          markdown = {
            enable = true;
            format.type = "prettierd";
          };
          go.enable = true;
          yaml.enable = true;
          bash.enable = true;
          clang.enable = true;
          helm.enable = true;
          python.enable = true;
        };
      };
    };
  };
}

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

        assistant.codecompanion-nvim = {
          enable = true;
          setupOpts = {
            adapters = lib.generators.mkLuaInline ''
              {
                openrouter = function()
                  return require("codecompanion.adapters").extend("openai_compatible", {
                    env = {
                      api_key = vim.env.OPENROUTER_API_KEY,
                      url = "https://openrouter.ai/api",
                      chat_url = "/v1/chat/completions",
                    },
                    schema = {
                      model = {
                        default = "google/gemini-2.5-pro-preview",
                        gemini = "google/gemini-2.5-pro-preview",
                        claude_35 = "anthropic/claude-3.5-sonnet",
                        claude_37 = "anthropic/claude-3.7-sonnet",
                      },
                    },
                  })
                end,
               }
            '';

            strategies = {
              chat = {
                adapter = "openrouter";
              };
              inline = {
                adapter = "openrouter";
              };
              cmd = {
                adapter = "openrouter";
              };
            };
            display = {
              chat = {
                auto_scroll = true;
                show_settings = true;
              };
              action_palette.provider = "telescope";
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

        dashboard.alpha.enable = true;

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix = {
            enable = true;
            lsp.package = pkgs.nil;
          };

          markdown.enable = true;
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

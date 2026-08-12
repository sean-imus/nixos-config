{ inputs, ... }:
{
  # Use NixVim to declaratively manage NeoVim
  flake-file.inputs.nixvim = {
    url = "github:nix-community/nixvim";
  };

  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      # Import the NixVim Home-Manager module to use its options
      imports = [ inputs.nixvim.homeModules.nixvim ];

      # Set NeoVim Alias & Environment Variable for easier usage
      home = {
        shellAliases.n = "nvim";
        sessionVariables.EDITOR = "nvim";
      };

      # Enable NixVim and set meta options
      programs.nixvim = {
        enable = true;
        waylandSupport = true;
        globals.mapleader = " ";

        # NeoVim options
        opts = {
          number = true;
          relativenumber = true;
          autoread = true;
          tabstop = 2;
          shiftwidth = 2;
          clipboard = "unnamedplus";
        };

        # NeoVim plugins and their settings
        plugins = {
          web-devicons.enable = true;
          gitsigns.enable = true;
          lazygit.enable = true;
          nvim-autopairs.enable = true;
          treesitter = {
            enable = true;
            grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
              nix
              bash
            ];
          };
          lualine.enable = true;
          noice = {
            enable = true;
            settings.lsp.override = {
              "vim.lsp.util.convert_input_to_markdown_lines" = true;
              "vim.lsp.util.stylize_markdown" = true;
            };
          };

          # Use nixd as the lsp of choice
          lsp = {
            enable = true;
            inlayHints = true;
            servers.nixd.enable = true;
          };

          # Handle formatting
          conform-nvim = {
            enable = true;
            autoInstall.enable = true;
            settings = {
              formatters_by_ft = {
                nix = [ "nixfmt" ];
              };
              format_on_save = {
                timeout_ms = 500;
                lsp_format = "fallback";
              };
            };
          };

          # Enable a file manager that can be invoked inside NeoVim
          neo-tree = {
            enable = true;
            settings = {
              close_if_last_window = true;
              filesystem = {
                follow_current_file.enabled = true;
                use_libuv_file_watcher = true;
                auto_reload = true;
              };
            };
          };
        };

        # Set theme
        colorschemes.everforest = {
          enable = true;
        };

        # Keybinds
        keymaps = [
          {
            key = "<leader>e";
            action = "<cmd>Neotree toggle<CR>";
            options.desc = "Toggle file explorer";
          }
          {
            key = "<leader>lg";
            action = "<cmd>LazyGit<CR>";
            options.desc = "Open lazygit";
          }
          {
            key = "<leader>h";
            action = "<cmd>nohlsearch<CR>";
            options.desc = "Clear search highlights";
          }
          {
            key = "<leader>q";
            action = "<cmd>q<CR>";
            options.desc = "Close window";
          }
          {
            key = "<leader>w";
            action = "<cmd>w<CR>";
            options.desc = "Save file";
          }
        ];

        # Watch files so if something changes from the outside it is immmediately reflected
        extraConfigLua = ''
          vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
            pattern = "*",
            command = "checktime",
          })
        '';
      };
    };
}

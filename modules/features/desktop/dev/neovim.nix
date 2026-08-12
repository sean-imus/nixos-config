{ inputs, ... }:
{
  # Nixvim manages its own pinned nixpkgs; no follows here (drift breaks vimPlugins)
  flake-file.inputs.nixvim = {
    url = "github:nix-community/nixvim";
  };

  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      home.shellAliases.n = "nvim";
      home.sessionVariables.EDITOR = "nvim";

      # Runtime dependencies for the editor itself; formatters come via conform autoInstall
      home.packages = with pkgs; [
        ripgrep
        nixd
      ];

      programs.nixvim = {
        enable = true;
        waylandSupport = true;
        globals.mapleader = " ";

        opts = {
          number = true;
          relativenumber = true;
          autoread = true;
          # nixfmt (RFC 166) mandates 2-space indentation, so this is correct for .nix
          tabstop = 2;
          shiftwidth = 2;
          clipboard = "unnamedplus";
        };

        plugins = {
          web-devicons.enable = true;
          gitsigns.enable = true;
          lazygit.enable = true;
          nvim-autopairs.enable = true;
          treesitter = {
            enable = true;
            grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
              nix
              lua
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

          lsp = {
            enable = true;
            inlayHints = true;
            keymaps = {
              lspBuf = {
                K = "hover";
                gd = "definition";
                gi = "implementation";
                gr = "references";
              };
              diagnostic = {
                "<leader>j" = "goto_next";
                "<leader>k" = "goto_prev";
              };
            };
            servers.nixd = {
              enable = true;
              settings.formatting.command = [ "nixfmt" ];
            };
          };

          # Owns all formatting; installs the formatters from formatters_by_ft itself
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

        colorschemes.everforest = {
          enable = true;
          settings.transparent_background = 2;
        };

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

        extraConfigLua = ''
          -- OSC 52 clipboard provider (no wl-clipboard package needed; requires an OSC52-capable terminal)
          vim.g.clipboard = {
            name = "OSC 52",
            copy = {
              ["+"] = require('vim.ui.clipboard.osc52').copy('+'),
              ["*"] = require('vim.ui.clipboard.osc52').copy('*'),
            },
            paste = {
              ["+"] = require('vim.ui.clipboard.osc52').paste('+'),
              ["*"] = require('vim.ui.clipboard.osc52').paste('*'),
            },
          }

          vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
            pattern = "*",
            command = "checktime",
          })
        '';
      };
    };
}

{ inputs, ... }:
{
  flake-file.inputs.nixvim = {
    url = "github:nix-community/nixvim";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      home.shellAliases.n = "nvim";
      home.sessionVariables.EDITOR = "nvim";

      home.packages = with pkgs; [
        ripgrep
        wl-clipboard
        nixd
        nixfmt
        python3Packages.isort
        python3Packages.black
      ];

      programs.nixvim = {
        enable = true;
        nixpkgs.source = inputs.nixpkgs;
        version.enableNixpkgsReleaseCheck = false;
        waylandSupport = true;
        colorscheme = "everforest";
        globals.mapleader = " ";

        opts = {
          number = true;
          relativenumber = true;
          autoread = true;
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
              python
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
            servers = {
              nixd = {
                enable = true;
                settings.formatting.command = [ "nixfmt" ];
              };
              pylsp.enable = true;
            };
          };

          conform-nvim = {
            enable = true;
            settings = {
              format_on_save = {
                lsp_format = "fallback";
                timeout_ms = 500;
              };
              formatters_by_ft = {
                nix = [ "nixfmt" ];
                python = [
                  "isort"
                  "black"
                ];
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
          vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
            pattern = "*",
            command = "checktime",
          })
        '';
      };
    };
}

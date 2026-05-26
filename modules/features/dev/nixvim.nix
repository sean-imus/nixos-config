{ inputs, lib, ... }:
{
  flake.modules.nixos.nixvim = { config, ... }: {
    options.userCfg.nixvim.enable = lib.mkEnableOption "Nixvim (Neovim)";
    config = lib.mkIf config.userCfg.nixvim.enable {
      home-manager.users.sean.imports = [
        inputs.self.modules.homeManager.nixvim
        inputs.nixvim.homeModules.nixvim
      ];
    };
  };

  flake-file.inputs.nixvim = {
    url = "github:nix-community/nixvim";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.nixvim =
    { ... }:
    {
      home.shellAliases.n = "nvim";
      home.sessionVariables.EDITOR = "nvim";

      programs.nixvim = {
        enable = true;
        colorscheme = "everforest";
        globals.mapleader = " ";

        opts = {
          number = true;
          relativenumber = true;
          autoread = true;
          tabstop = 2;
          shiftwidth = 2;
        };

        plugins = {
          web-devicons.enable = true;
          gitsigns.enable = true;
          lazygit.enable = true;
          nvim-autopairs.enable = true;
          which-key.enable = true;
          treesitter.enable = true;
          lualine.enable = true;
          snacks.enable = true;
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
            autoInstall.enable = true;
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

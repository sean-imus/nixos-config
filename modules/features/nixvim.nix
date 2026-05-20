{ ... }:
{
  flake-file.inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.nixvim =
    { ... }:
    {
      home.shellAliases = {
        n = "nvim";
      };

      home.sessionVariables.EDITOR = "nvim";

      programs.nixvim = {
        enable = true;

        colorscheme = "everforest";

        globals.mapleader = " ";

        opts = {
          number = true;
          relativenumber = true;
          autoread = true;
        };

        plugins.web-devicons.enable = true;
        plugins.gitsigns.enable = true;
        plugins.lazygit.enable = true;
        plugins.nvim-autopairs.enable = true;
        plugins.which-key.enable = true;
        plugins.treesitter.enable = true;
        plugins.lualine.enable = true;
        plugins.noice.enable = true;

        plugins.lsp = {
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
              settings.formatting.command = [ "nixpkgs-fmt" ];
            };
            pylsp.enable = true;
          };
        };

        plugins.neo-tree = {
          enable = true;
          settings = {
            close_if_last_window = true;
            filesystem = {
              follow_current_file.enabled = true;
              use_libuv_file_watcher = true;
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

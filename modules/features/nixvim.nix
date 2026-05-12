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

        opts = {
          number = true;
          relativenumber = true;
        };

        plugins.gitsigns.enable = true;

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
            filesystem.follow_current_file.enabled = true;
          };
        };

        keymaps = [
          {
            key = "<leader>e";
            action = "<cmd>Neotree toggle<CR>";
            options.desc = "Toggle file explorer";
          }
        ];

        extraConfigLua = ''
          vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE', ctermbg = 'NONE' })
          vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', ctermbg = 'NONE' })
          vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE', ctermbg = 'NONE' })
          vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'NONE', ctermbg = 'NONE' })
          vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE', ctermbg = 'NONE' })
          vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE', ctermbg = 'NONE' })
        '';
      };
    };
}

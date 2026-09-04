{ inputs, pkgs, ... }:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  home = {
    shellAliases.n = "nvim";
    sessionVariables.EDITOR = "nvim";
  };

  programs.nixvim = {
    enable = true;
    waylandSupport = true;
    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      autoread = true;
      tabstop = 2;
      shiftwidth = 2;
      clipboard = "unnamedplus";
      foldlevelstart = 99;
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
          bash
          python
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
      };

      blink-cmp = {
        enable = true;
        settings.keymap.preset = "super-tab";
      };

      which-key.enable = true;
      comment.enable = true;

      todo-comments = {
        enable = true;
        keymaps.todoTelescope.key = "<leader>ft";
      };

      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
        };
      };

      indent-blankline.enable = true;
      flash.enable = true;

      conform-nvim = {
        enable = true;
        autoInstall.enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            python = [ "ruff_format" ];
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
          window.mappings = {
            S = "open_vsplit";
            s = false;
          };
        };
      };
    };

    colorschemes.everforest.enable = true;

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
      {
        key = "s";
        action = "<cmd>lua require('flash').jump()<CR>";
        options.desc = "Flash jump";
      }
    ];

    extraConfigLua = ''
      vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
        pattern = "*",
        command = "checktime",
      })
    '';
  };
}

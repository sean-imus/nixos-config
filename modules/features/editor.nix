{ inputs, pkgs, ... }:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  home = {
    shellAliases = {
      n = "nvim";
      p = "python3";
    };
    sessionVariables.EDITOR = "nvim";
    packages = with pkgs; [ python3 ];
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
      updatetime = 250;
    };

    autoCmd = [
      {
        event = [
          "FocusGained"
          "BufEnter"
          "CursorHold"
        ];
        pattern = "*";
        command = "checktime";
      }
    ];

    performance.byteCompileLua = {
      enable = true;
      plugins = true;
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
        servers = {
          nixd = {
            enable = true;
            settings = {
              nixpkgs.expr = "import ${inputs.nixpkgs.outPath} { }";
              formatting.command = [ "nixfmt" ];
              options = {
                nixos.expr = "(builtins.getFlake (toString ${inputs.self.outPath})).nixosConfigurations.notebook.options";
                home-manager.expr = "(builtins.getFlake (toString ${inputs.self.outPath})).nixosConfigurations.notebook.options.home-manager.users.type.getSubOptions []";
              };
            };
          };
          pyright.enable = true;
        };
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
          "<leader>fd" = "diagnostics";
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

      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          float_opts.border = "curved";
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
      {
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
        options.desc = "Show docs: option/value explanation (LSP hover)";
      }
      {
        key = "gK";
        action = "<cmd>lua vim.lsp.buf.signature_help()<CR>";
        options.desc = "Show function signature";
      }
      {
        key = "<leader>d";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Show diagnostic details under cursor";
      }
      {
        key = "<leader>r";
        action = "<cmd>RunFile<CR>";
        options.desc = "Run current file (per filetype)";
      }
      {
        key = "<leader>tt";
        action = "<cmd>ToggleTerm<CR>";
        options.desc = "Toggle terminal";
      }
    ];

    userCommands.RunFile = {
      desc = "Run current file in a split terminal, per filetype";
      command.__raw = ''
        function()
          local runners = {
            python = "python3 %",
            bash = "bash %",
            sh = "bash %",
            fish = "fish %",
            lua = "lua %",
            ruby = "ruby %",
            javascript = "node %",
            typescript = "deno run -A %",
          }
          local cmd = runners[vim.bo.filetype]
          if not cmd then
            vim.notify("No runner mapped for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
            return
          end
          vim.cmd.write()
          vim.cmd("belowright 15split | term " .. cmd)
          vim.cmd.startinsert()
        end
      '';
    };
  };
}

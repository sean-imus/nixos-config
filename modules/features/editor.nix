{
  config,
  inputs,
  pkgs,
  shadowDesktopEntries,
  ...
}:
let
  flake = ''(builtins.getFlake "${config.programs.nh.flake}").nixosConfigurations.notebook'';
  map = key: action: desc: {
    inherit key action;
    options = { inherit desc; };
  };
in
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  home = {
    shellAliases = {
      n = "nvim";
      p = "python3";
    };
    sessionVariables.EDITOR = "nvim";
    packages = with pkgs; [
      nixfmt
      python3
    ];
  };

  programs.nixvim = {
    enable = true;
    enableMan = false;
    enablePrintInit = false;
    withRuby = false;
    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      ignorecase = true;
      smartcase = true;
      scrolloff = 5;
      undofile = true;
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
          json
          yaml
          toml
          lua
          vim
          vimdoc
          markdown
          markdown_inline
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
              nixpkgs.expr = "import ${inputs.nixpkgs} { }";
              formatting.command = [ "nixfmt" ];
              options = {
                nixos.expr = "${flake}.options";
                home-manager.expr = "${flake}.options.home-manager.users.type.getSubOptions []";
              };
            };
          };
          pyright.enable = true;
          ruff.enable = true;
        };
      };

      blink-cmp = {
        enable = true;
        settings.keymap.preset = "super-tab";
      };

      which-key.enable = true;

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
      fidget.enable = true;
      grug-far.enable = true;
      mini-surround.enable = true;
      render-markdown.enable = true;

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
      (map "<leader>e" "<cmd>Neotree toggle<CR>" "Toggle file explorer")
      (map "<leader>lg" "<cmd>LazyGit<CR>" "Open lazygit")
      (map "<leader>h" "<cmd>nohlsearch<CR>" "Clear search highlights")
      (map "<leader>q" "<cmd>q<CR>" "Close window")
      (map "<leader>w" "<cmd>w<CR>" "Save file")
      (map "s" "<cmd>lua require('flash').jump()<CR>" "Flash jump")
      (map "K" "<cmd>lua vim.lsp.buf.hover()<CR>" "Show docs: option/value explanation (LSP hover)")
      (map "gK" "<cmd>lua vim.lsp.buf.signature_help()<CR>" "Show function signature")
      (map "<leader>d" "<cmd>lua vim.diagnostic.open_float()<CR>" "Show diagnostic details under cursor")
      (map "<leader>r" "<cmd>RunFile<CR>" "Run current file (per filetype)")
      (map "<leader>sr" "<cmd>GrugFar<CR>" "Search and replace (project)")
      (map "<leader>tt" "<cmd>ToggleTerm<CR>" "Toggle terminal")
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
  xdg.dataFile = shadowDesktopEntries [ config.programs.nixvim.build.packageUnchecked ] [ "nvim" ];
}

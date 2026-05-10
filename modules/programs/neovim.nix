{ ... }: {
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    home.shellAliases = {
      n = "nvim";
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      withRuby = false;
      withPython3 = false;

      plugins = with pkgs.vimPlugins; [
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            require('gitsigns').setup {}
          '';
        }
      ];

      initLua = ''
        vim.lsp.config('nixd', {
          cmd = { "nixd" },
          filetypes = { "nix" },
        })
        vim.lsp.enable('nixd')

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

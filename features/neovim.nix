{ pkgs, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Setup Neovim Alias
    home.shellAliases = {
      n = "nvim";
    };

    # Install Neovim
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

      # Install Nix LSP
      initLua = ''
        vim.lsp.config('nixd', {
          cmd = { "nixd" },
          filetypes = { "nix" },
        })
        vim.lsp.enable('nixd')
      '';
    };
  };
}

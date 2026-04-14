{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;
    extraPackages = [ pkgs.nixd ];

    plugins = with pkgs.vimPlugins; [
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup {}
        '';
      }
    ];

    extraLuaConfig = ''
      vim.lsp.config('nixd', {
        cmd = { "nixd" },
        filetypes = { "nix" },
      })
      vim.lsp.enable('nixd')
    '';
  };
}

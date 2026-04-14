{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withRuby = false; # Silence Warning
    withPython3 = false; # Silence Warning
    plugins = [
      pkgs.gitsigns-nvim
    ];
    extraPackages = [
      pkgs.nixd
    ];
  };
}

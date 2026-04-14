{ ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withRuby = false; # Silence Warning
    withPython3 = false; # Silence Warning
  };
}

{ ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      lg = lazygit;
      c = opencode;
    };
  };
}
{ ... }:
{
  flake.modules.homeManager.terminal = {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
          };
          size = 10;
        };
        scrolling.multiplier = 5;
      };
    };
  };
}

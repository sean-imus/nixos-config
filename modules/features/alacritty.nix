{ ... }:
{
  flake.modules.homeManager.alacritty = {
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
        window.opacity = 0.65;
      };
    };
  };
}

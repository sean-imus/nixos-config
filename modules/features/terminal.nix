{ lib, ... }:
{
  flake.modules.nixos.terminal = {
    options.userCfg.terminal.enable = lib.mkEnableOption "Alacritty terminal emulator";
  };

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
        window.opacity = 0.65;
      };
    };
  };
}

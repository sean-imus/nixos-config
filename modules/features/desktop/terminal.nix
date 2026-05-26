{ inputs, lib, ... }:
{
  flake.modules.nixos.terminal = { config, ... }: {
    options.userCfg.terminal.enable = lib.mkEnableOption "Alacritty terminal emulator";
    config = lib.mkIf config.userCfg.terminal.enable {
      home-manager.users.sean.imports = [ inputs.self.modules.homeManager.terminal ];
    };
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

{ ... }:
{
  flake.modules.nixos.waybar =
    { ... }:
    { };

  flake.modules.homeManager.waybar =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        waybar
      ];

      xdg.configFile."waybar/config.jsonc" = {
        source = ./config.jsonc;
        force = true;
      };

      xdg.configFile."waybar/style.css" = {
        source = ./style.css;
        force = true;
      };
    };
}

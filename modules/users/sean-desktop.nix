{ inputs, ... }:
{
  flake.modules.nixos.sean-desktop = { ... }: {
    imports = with inputs.self.modules.nixos; [
      sean
      niri
      rdp-work
      printing
      filesharing
      lockscreen
    ];

    home-manager.users.sean.imports = with inputs.self.modules.homeManager; [
      application-launcher
      bar
      browser
      calc
      discord
      filesharing
      games
      gtk
      lockscreen
      notifications
      niri
      office-suite
      printing
      rdp-work
      terminal
      wallpaper
    ];
  };
}

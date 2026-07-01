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
      discord
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
      niri
      office-suite
      printing
      qemu
      rdp-work
      screencap
      terminal
      wallpaper
    ];
  };
}

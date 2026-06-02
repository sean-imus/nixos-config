{ inputs, ... }:
{
  flake.modules.nixos.sean-desktop = { ... }: {
    imports = with inputs.self.modules.nixos; [
      sean
      niri
      rdp-work
      printing
      filesharing
    ];

    home-manager.users.sean.imports = with inputs.self.modules.homeManager; [
      application-launcher
      bar
      browser
      discord
      filesharing
      lockscreen
      notifications
      niri
      office-suite
      printing
      rdp-work
      terminal
    ];
  };
}

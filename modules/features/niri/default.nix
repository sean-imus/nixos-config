{ pkgs, ... }:
{
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  environment.systemPackages = [
    pkgs.brightnessctl
    pkgs.wl-clipboard
    pkgs.cliphist
    pkgs.playerctl
    pkgs.wiremix
    pkgs.bluetui
  ];

  home-manager.sharedModules = [
    ./keybindings.nix
    ./outputs.nix
    ./settings.nix
    {
      wayland.windowManager.niri = {
        enable = true;
        portalPackage = null;
        systemd.enable = false;
      };
    }
  ];
}

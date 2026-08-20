{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    wl-clipboard
    cliphist
    playerctl
    wiremix
    bluetui
    grimblast
    slurp
    swappy
    gpu-screen-recorder
    hyprpicker
    pwvucontrol
    btop
    fastfetch
  ];

  home-manager.sharedModules = [
    ./settings.nix
  ];
}

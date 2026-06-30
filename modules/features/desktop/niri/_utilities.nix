{ pkgs, ... }:
{
  programs.niri.settings.binds = {
    "Mod+Ctrl+B".action.spawn = [
      "alacritty"
      "--class"
      "bluetui"
      "-e"
      "bluetui"
    ];
    "Mod+Ctrl+A".action.spawn = [
      "alacritty"
      "--class"
      "wiremix"
      "-e"
      "wiremix"
      "-v"
      "playback"
    ];
    "Mod+Y".action.spawn = [
      "sh"
      "-c"
      "cliphist list | fuzzel --dmenu --with-nth 2 | cliphist decode | wl-copy"
    ];
    "Mod+P".action.spawn = "power-toggle";
  };

  programs.niri.settings.window-rules = [
    {
      matches = [ { app-id = "^wiremix$"; } ];
      open-floating = true;
    }
    {
      matches = [ { app-id = "^bluetui$"; } ];
      open-floating = true;
    }
  ];

  programs.niri.settings.spawn-at-startup = [
    {
      argv = [
        "wl-paste"
        "--watch"
        "cliphist"
        "store"
      ];
    }
    {
      argv = [
        "wl-paste"
        "--type"
        "image/png"
        "--watch"
        "cliphist"
        "store"
      ];
    }
  ];

  services.playerctld.enable = true;

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "vaapi";
      vo = "gpu";
      gpu-context = "wayland";
    };
  };

  xdg.dataFile = {
    "applications/cups.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    "applications/nixos-manual.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    "applications/btop.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    "applications/nvim.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    "applications/mpv.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
  };

  home.packages = with pkgs; [
    xwayland-satellite
    wiremix
    bluetui
    brightnessctl
    wl-clipboard
    cliphist
    (pkgs.writeShellScriptBin "perf-status" ''
      raw=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile)
      current=''${raw#s \"}
      current=''${current%\"}
      case "$current" in
        power-saver) echo '{"text":"PERF low","class":"low","tooltip":"power-saver"}' ;;
        balanced)    echo '{"text":"PERF med","class":"med","tooltip":"balanced"}' ;;
        performance) echo '{"text":"PERF high","class":"high","tooltip":"performance"}' ;;
      esac
    '')
    (pkgs.writeShellScriptBin "power-toggle" ''
      raw=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile)
      current=''${raw#s \"}
      current=''${current%\"}
      case "$current" in
        power-saver) next="balanced" ;;
        balanced) next="performance" ;;
        performance) next="power-saver" ;;
      esac
      busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "$next"
      pkill -RTMIN+9 waybar
    '')
  ];
}

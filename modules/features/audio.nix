{
  flake.modules = {
    nixos.audio = {
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
      };

      security.rtkit.enable = true;
    };

    homeManager.audio =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        locked = spawn-sh: {
          _props.allow-when-locked = true;
          inherit spawn-sh;
        };
      in
      {
        home.packages = [ pkgs.wiremix ];

        wayland.windowManager.niri.settings = {
          binds = {
            "XF86AudioRaiseVolume" = locked "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
            "XF86AudioLowerVolume" = locked "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            "XF86AudioMute" = locked "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioMicMute" = locked "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            "Mod+Ctrl+A".spawn = [
              (lib.getExe config.programs.foot.package)
              "--app-id"
              "wiremix"
              "wiremix"
              "-v"
              "playback"
            ];
          };

          _children = [
            {
              window-rule._children = [
                {
                  match._props.app-id = "^wiremix$";
                  open-floating = true;
                }
              ];
            }
          ];
        };
      };
  };
}

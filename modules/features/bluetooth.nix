{
  flake.modules = {
    nixos.bluetooth = {
      hardware.bluetooth.enable = true;
    };

    homeManager.bluetooth =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        home.packages = [ pkgs.bluetui ];

        wayland.windowManager.niri.settings = {
          binds."Mod+Ctrl+B".spawn = [
            (lib.getExe config.programs.foot.package)
            "--app-id"
            "bluetui"
            "bluetui"
          ];

          _children = [
            {
              window-rule._children = [
                {
                  match._props.app-id = "^bluetui$";
                  open-floating = true;
                }
              ];
            }
          ];
        };
      };
  };
}

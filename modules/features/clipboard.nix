{
  flake.modules.homeManager.clipboard =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      watch = args: {
        spawn-at-startup._args = [
          "wl-paste"
        ]
        ++ args
        ++ [
          "--watch"
          "cliphist"
          "store"
        ];
      };
    in
    {
      home.packages = [
        pkgs.wl-clipboard
        pkgs.cliphist
      ];

      wayland.windowManager.niri.settings = {
        _children = [
          (watch [ ])
          (watch [
            "--type"
            "image/png"
          ])
        ];

        binds."Mod+Ctrl+Y".spawn-sh =
          "cliphist list | ${lib.getExe config.programs.fuzzel.package} --dmenu --with-nth 2 | cliphist decode | wl-copy";

        clipboard.disable-primary = { };
      };
    };
}

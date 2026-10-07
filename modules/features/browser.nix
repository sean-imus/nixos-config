{
  lib,
  pkgs,
  theme,
  shadowDesktopEntries,
  ...
}:
let
  # Chromium installs external extensions per user-data-dir, so every profile
  # is its own data dir. That is what keeps Claude out of all but Privat.
  profiles = {
    work-admin = "Work-Admin";
    work-normal = "Work-Normal";
    school = "School";
    privat = "Privat";
  };

  ublockLite = "ddkjiahejlhfcafbddmgiahcphecmpfh";
  vimium = "dbepggeogbaibhgnhhndojpepiihcmeb";
  claude = "fcoeoabgfenejglbffodgkkbkcdhcgfn";

  commonExtensions = [
    ublockLite
    vimium
  ];
  extensionsFor = key: commonExtensions ++ lib.optional (key == "privat") claude;

  colour = c: builtins.fromJSON "[${c}]";

  # Unpacked theme extension, loaded per launch with --load-extension.
  everforestTheme = pkgs.writeTextDir "manifest.json" (
    builtins.toJSON {
      manifest_version = 3;
      name = "Everforest";
      version = "1.0";
      theme.colors = {
        frame = colour theme.rgb.bg0;
        frame_inactive = colour theme.rgb.bg1;
        toolbar = colour theme.rgb.bg1;
        toolbar_text = colour theme.rgb.fg;
        toolbar_button_icon = colour theme.rgb.fg;
        tab_text = colour theme.rgb.fg;
        tab_background_text = colour theme.rgb.grey1;
        bookmark_text = colour theme.rgb.fg;
        omnibox_background = colour theme.rgb.bg2;
        omnibox_text = colour theme.rgb.fg;
        ntp_background = colour theme.rgb.bg0;
        ntp_text = colour theme.rgb.fg;
        ntp_link = colour theme.rgb.green;
      };
    }
  );

  updateUrl = builtins.toJSON {
    external_update_url = "https://clients2.google.com/service/update2/crx";
  };
in
{
  programs.chromium.enable = true;

  # --password-store=basic: autologin never hands PAM a password, so the
  # gnome-keyring login keyring stays locked and Chromium would prompt on launch.
  home.packages = lib.mapAttrsToList (
    key: _:
    pkgs.writeShellScriptBin "chromium-${key}" ''
      exec chromium \
        --password-store=basic \
        --force-dark-mode \
        --enable-features=WebUIDarkMode \
        --load-extension=${everforestTheme} \
        --user-data-dir="$HOME/.config/chromium-${key}" "$@"
    ''
  ) profiles;

  xdg.desktopEntries = lib.mapAttrs' (
    key: name:
    lib.nameValuePair "chromium-${key}" {
      name = "Chromium (${name})";
      genericName = "Web Browser";
      exec = "chromium-${key} %U";
      icon = "chromium";
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
    }
  ) profiles;

  home.file = lib.listToAttrs (
    lib.concatLists (
      lib.mapAttrsToList (
        key: _:
        map (id: {
          name = ".config/chromium-${key}/External Extensions/${id}.json";
          value.text = updateUrl;
        }) (extensionsFor key)
      ) profiles
    )
  );

  xdg.dataFile = shadowDesktopEntries [ pkgs.chromium ] [ "chromium-browser" ];
}

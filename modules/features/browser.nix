{
  lib,
  pkgs,
  theme,
  shadowDesktopEntries,
  ...
}:
let
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

  everforestTheme = pkgs.writeTextDir "manifest.json" (
    builtins.toJSON {
      manifest_version = 3;
      name = "Everforest";
      version = "1.0";
      theme.colors = {
        frame = theme.rgb.bg0;
        frame_inactive = theme.rgb.bg1;
        toolbar = theme.rgb.bg1;
        toolbar_text = theme.rgb.fg;
        toolbar_button_icon = theme.rgb.fg;
        tab_text = theme.rgb.fg;
        tab_background_text = theme.rgb.grey1;
        bookmark_text = theme.rgb.fg;
        omnibox_background = theme.rgb.bg2;
        omnibox_text = theme.rgb.fg;
        ntp_background = theme.rgb.bg0;
        ntp_text = theme.rgb.fg;
        ntp_link = theme.rgb.green;
      };
    }
  );

  updateUrl = builtins.toJSON {
    external_update_url = "https://clients2.google.com/service/update2/crx";
  };
in
{
  programs.chromium.enable = true;

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

  home.file = lib.concatMapAttrs (
    key: _:
    lib.genAttrs' (extensionsFor key) (
      id: lib.nameValuePair ".config/chromium-${key}/External Extensions/${id}.json" { text = updateUrl; }
    )
  ) profiles;

  xdg = {
    desktopEntries = lib.mapAttrs' (
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
    mimeApps.defaultApplications = lib.genAttrs [
      "application/json"
      "application/pdf"
      "image/avif"
      "image/bmp"
      "image/gif"
      "image/jpeg"
      "image/png"
      "image/svg+xml"
      "image/webp"
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ] (_: "chromium-privat.desktop");
    dataFile = shadowDesktopEntries [ pkgs.chromium ] [ "chromium-browser" ];
  };
}

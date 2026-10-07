{ lib, pkgs, ... }:
let
  shadowDesktopEntries = import ../lib/desktop-entries.nix { inherit pkgs; };

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
      exec chromium --password-store=basic --user-data-dir="$HOME/.config/chromium-${key}" "$@"
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

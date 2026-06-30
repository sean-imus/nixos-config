{ ... }:
{
  flake.modules.nixos.wifi =
    { config, lib, ... }:
    let
      networks = {
        "home-wifi" = "NET-Tietz-Ibryam-5Ghz";
        "parents-wifi" = "WLAN von VatosLocos 5GHz";
        "work-guest-wifi" = "ENTEXGuests";
      };

      openNetworks = {
        "school-wifi" = "BYOD-TBS";
      };

      secretKey = name: "wifi_${lib.replaceStrings [ "-" ] [ "_" ] name}_psk";

      mkProfile = name: ssid: {
        connection = {
          id = name;
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          inherit ssid;
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk-flags = 1;
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      mkOpenProfile = name: ssid: {
        connection = {
          id = name;
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          inherit ssid;
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      mkSecretEntry = name: {
        file = config.sops.secrets.${secretKey name}.path;
        key = "psk";
        matchId = name;
        matchSetting = "802-11-wireless-security";
        matchType = "802-11-wireless";
        trim = true;
      };
    in
    {
      sops.secrets = lib.mapAttrs' (name: _: lib.nameValuePair (secretKey name) { }) networks;

      networking.networkmanager.ensureProfiles = {
        profiles = (lib.mapAttrs mkProfile networks) // (lib.mapAttrs mkOpenProfile openNetworks);
        secrets.entries = lib.mapAttrsToList (name: _: mkSecretEntry name) networks;
      };
    };
}

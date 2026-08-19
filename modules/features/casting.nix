{
  pkgs,
  lib,
  ...
}:
let
  fluxcast = pkgs.python3Packages.buildPythonApplication rec {
    pname = "fluxcast";
    version = "0.2.1-unstable-2025-08-18";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "IlyaP358";
      repo = "fluxcast";
      rev = "9d27c39670940ada3a0e520a1d70574910646083";
      hash = "sha256-VRzJPO5F+LAyNp9KtO1MC7nnqhHbOpN+p464waGTjAk=";
    };

    patches = [ ./patches/fluxcast-dbus-p2p.patch ];

    nativeBuildInputs = with pkgs; [
      python3Packages.hatchling
      gobject-introspection
      pkg-config
    ];

    build-system = with pkgs.python3Packages; [
      hatchling
    ];

    propagatedBuildInputs =
      with pkgs.python3Packages;
      [
        upnpclient
        pychromecast
        dbus-next
        pillow
        pystray
        pygobject3
      ]
      ++ [
        pkgs.gobject-introspection
      ];

    nativeCheckInputs = [ ];

    # fluxcast has no test suite
    doCheck = false;

    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [
        pkgs.ffmpeg
        pkgs.wf-recorder
        pkgs.networkmanager
        pkgs.wpa_supplicant
        pkgs.iw
        pkgs.pulseaudio
        pkgs.glib
        pkgs.dnsmasq
        pkgs.dhcpcd
        pkgs.coreutils
        pkgs.iproute2
        pkgs.procps
        pkgs.xrandr
      ])
    ];

    postInstall = ''
            mkdir -p $out/share/applications
            mkdir -p $out/share/icons/hicolor/512x512/apps
            mkdir -p $out/share/dbus-1/system.d

            cat > $out/share/applications/fluxcast.desktop << 'DESKTOP'
      [Desktop Entry]
      Name=FluxCast
      Comment=Stream your desktop to a Smart TV via Miracast/DLNA
      Exec=kitty --class fluxcast fluxcast --wfd-no-firewall --wfd-capture-backend wf-recorder
      Icon=fluxcast
      Terminal=false
      Type=Application
      Categories=AudioVideo;Video;Network;
      DESKTOP

            cp src/assets/flcast_logo_512x512.png $out/share/icons/hicolor/512x512/apps/fluxcast.png

            cp meta/zz-dev.fluxcast.wpa-supplicant.conf $out/share/dbus-1/system.d/
    '';

    meta = with lib; {
      description = "Stream your Linux desktop to a Smart TV via Miracast/WFD, DLNA, or Chromecast";
      homepage = "https://github.com/IlyaP358/fluxcast";
      license = licenses.gpl3Plus;
      mainProgram = "fluxcast";
    };
  };
in
{
  environment.systemPackages = [ fluxcast ];

  # wpa_supplicant hardening puts it in a chroot that breaks D-Bus socket access.
  # We need direct D-Bus access for P2P peer discovery (bypasses NM's broken peer tracking).
  networking.wireless.enableHardening = false;

  # Override the udev rule that restarts wpa_supplicant on wlan add/remove.
  # This interferes with P2P connection setup (NM creates p2p-dev interfaces
  # which trigger the restart, killing the ongoing connection).
  # Since we use NetworkManager for wifi, we don't need this rule.
  services.udev.extraRules = lib.mkForce "";

  services.dbus.packages = [ fluxcast ];

  environment.variables."FLUXCAST_NO_FIREWALL" = "1";

  networking.firewall.allowedTCPPorts = [ 7236 ];
}

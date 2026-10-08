{
  flake.modules.nixos.hardware-dev =
    { lib, pkgs, ... }:
    let
      serialRule =
        {
          vendor,
          product,
        }:
        ''SUBSYSTEM=="tty", ATTRS{idVendor}=="${vendor}", ATTRS{idProduct}=="${product}", TAG+="uaccess", GROUP="dialout", MODE="0660"'';
    in
    {
      services.udev.extraRules = ''
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_USB_INTERFACES}=="*:ff420?:*", TAG+="uaccess", MODE="0660"
      ''
      + lib.concatMapStringsSep "\n" serialRule [
        {
          vendor = "10c4";
          product = "ea60";
        }
        {
          vendor = "1a86";
          product = "7523";
        }
        {
          vendor = "0403";
          product = "6001";
        }
        {
          vendor = "303a";
          product = "1001";
        }
      ];

      environment.systemPackages = [
        pkgs.android-tools
        pkgs.arduino-cli
        pkgs.arduino-ide
        pkgs.esptool
      ];
    };
}

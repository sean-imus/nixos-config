{ pkgs, ... }:
{
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_USB_INTERFACES}=="*:ff420?:*", TAG+="uaccess", MODE="0660"
  '';

  environment.systemPackages = with pkgs; [ android-tools ];
}

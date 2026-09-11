{
  pkgs,
  config,
  ...
}:
{
  users.users.sean.extraGroups = [ "dialout" ];

  services.udev.extraRules = ''
    # Silicon Labs CP210x (ESP32 dev boards)
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", TAG+="uaccess", GROUP="dialout", MODE="0660"
    # WCH CH340/CH341
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess", GROUP="dialout", MODE="0660"
    # FTDI
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", TAG+="uaccess", GROUP="dialout", MODE="0660"
    # ESP32-S3 native USB
    SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", TAG+="uaccess", GROUP="dialout", MODE="0660"
  '';

  environment.systemPackages = with pkgs; [
    arduino-cli
    arduino-ide
    esptool
  ];
}

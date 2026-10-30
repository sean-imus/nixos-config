{
  den.aspects.firmware.nixos = {
    hardware.enableRedistributableFirmware = true;
    services.fwupd.enable = true;
  };
}

{ inputs, ... }:
{
  flake.modules.nixos.server =
    { lib, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        ssh
        disko
        persistence
        sean
      ];

      hostCfg = {
        ssh-server.enable = lib.mkDefault true;
      };

      diskoConfigDevice = "/dev/disk/by-id/ata-TOSHIBA_MQ01ABD050_93HRC25TT";
      diskoSwapSize = "6G";

      networking.hostName = "server";

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "usbhid"
      ];
    };
}

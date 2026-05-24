{ inputs, ... }:
{
  flake.modules.nixos.server =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        impermanence
        sean-server
      ];

      hostCfg = {
        audio.enable = false;
        hm.enable = true;
      };

      diskoConfigDevice = "/dev/disk/by-id/ata-TOSHIBA_MQ01ABD050_93HRC25TT";

      networking.hostName = "server";

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "usbhid"
      ];
    };
}

{ inputs, ... }:
{
  flake.modules.nixos.server =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        impermanence
        sean
      ];

      hostCfg = {
        audio.enable = false;
        hm.enable = true;
      };

      diskoConfigDevice = "/dev/disk/by-id/FIXME-ME";

      networking.hostName = "server";

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "usbhid"
      ];
    };
}

{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        impermanence
        niri
        sean
      ];

      hostCfg = {
        audio.enable = true;
        hm.enable = true;
      };

      diskoConfigDevice = "/dev/disk/by-id/virtio-ROOT";

      networking.hostName = "vm";

      boot.initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];
    };
}

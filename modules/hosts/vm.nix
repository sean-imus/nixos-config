{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        persistence
        sean-desktop
      ];

      home-manager.users.sean.programs.niri.settings.input.mod-key = "Alt";

      diskoConfigDevice = "/dev/disk/by-id/virtio-ROOT";
      diskoSwapSize = "10G";

      networking.hostName = "vm";

      boot.initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];
    };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "vm";
}

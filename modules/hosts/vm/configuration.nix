{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { config, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        impermanence
        sean
      ];

      hostCfg = {
        hm.enable = true;
        audio.enable = true;
        niri.enable = true;
        user.sean = {
          gui.enable = true;
        };
      };

      home-manager.users.sean.programs.niri.settings.input.mod-key = "Alt";

      diskoConfigDevice = "/dev/disk/by-id/virtio-ROOT";

      networking.hostName = "vm";

      boot.initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
      ];

      environment.shellAliases = {
        rbs = "sudo nixos-rebuild switch --flake github:sean-imus/nixos-config#${config.networking.hostName}";
        rbb = "sudo nixos-rebuild boot --flake github:sean-imus/nixos-config#${config.networking.hostName} && reboot";
      };
    };
}

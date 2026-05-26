{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { config, ... }:
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
        user.sean.gui.enable = true;
        user.sean.dev.enable = false;
      };

      home-manager.users.sean.niri.config.modKey = "Alt";

      home-manager.users.sean.niri.config.monitorConfig = ''
        output "Virtual-1" {
            mode "1920x1080@60"
            position x=0 y=0
        }
      '';

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

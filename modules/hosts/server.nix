{ inputs, ... }:
{
  flake.modules.nixos.server =
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
        ssh-server.enable = true;
      };
      userCfg = {
        btop.enable = true;
        fastfetch.enable = true;
        git.enable = true;
        shell.enable = true;
        sops.enable = true;
        ssh.enable = true;
        nixvim.enable = true;
      };

      diskoConfigDevice = "/dev/disk/by-id/ata-TOSHIBA_MQ01ABD050_93HRC25TT";

      networking.hostName = "server";

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "usbhid"
      ];

      environment.shellAliases = {
        rbs = "sudo nixos-rebuild switch --flake github:sean-imus/nixos-config#${config.networking.hostName}";
        rbb = "sudo nixos-rebuild boot --flake github:sean-imus/nixos-config#${config.networking.hostName} && reboot";
      };
    };
}

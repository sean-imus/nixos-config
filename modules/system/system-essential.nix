{ inputs, ... }:
{
  flake.modules.nixos.systemEssential =
    { pkgs, config, ... }:
    {
      imports = [ inputs.self.modules.nixos.systemDefault ];

      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
      };

      boot.loader = {
        timeout = 1;
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 10;
      };

      environment.systemPackages = with pkgs; [
        lm_sensors
        pciutils
        usbutils
        iotop
        wget
        tldr
        bat
        zsh
      ];

      environment.shellAliases = {
        rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
        rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
      };

      users.mutableUsers = false;
    };
}

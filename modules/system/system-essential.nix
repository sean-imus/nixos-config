{ inputs, ... }: {
  flake.modules.nixos.systemEssential = { pkgs, config, ... }: {
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

    fileSystems."/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" "noatime" ];
    };
  };
}

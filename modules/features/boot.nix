{
  flake.modules.nixos.boot = {
    boot = {
      tmp.cleanOnBoot = true;

      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
          editor = false;
        };
        efi.canTouchEfiVariables = true;
        timeout = 0;
      };
    };
  };
}

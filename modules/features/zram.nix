{
  flake.modules.nixos.zram = {
    zramSwap.enable = true;

    boot.kernel.sysctl = {
      "vm.page-cluster" = 0;
      "vm.swappiness" = 180;
    };
  };
}

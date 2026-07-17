{ ... }:
{
  flake.modules.nixos.qemu =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ { userCfg.extraGroups = [ "libvirtd" ]; } ];

      virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };

      preservation.preserveAt."/persist".directories = [
        "/var/lib/libvirt/"
      ];

      programs.virt-manager.enable = true;

      # libvirt ships a `default` NAT network but doesn't define/start it on a
      # fresh (impermanent) boot — recreate it idempotently each start.
      systemd.services.libvirtd.postStart = ''
        ${pkgs.libvirt}/bin/virsh net-info default >/dev/null 2>&1 || \
        ${pkgs.libvirt}/bin/virsh net-define ${pkgs.libvirt}/var/lib/libvirt/qemu/networks/default.xml 2>/dev/null || true
        ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
        ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
      '';
    };
}

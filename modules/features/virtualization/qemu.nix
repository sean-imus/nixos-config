{ lib, ... }:
{
  flake.modules.nixos.qemu =
    { pkgs, config, ... }:
    {
      options.hostCfg.qemu.enable = lib.mkEnableOption "QEMU/KVM virtualization stack";

      config = lib.mkIf config.hostCfg.qemu.enable {
        virtualisation.libvirtd = {
          enable = true;
          qemu = {
            swtpm.enable = true;
          };
        };

        programs.virt-manager = {
          enable = true;
        };

        systemd.services.virt-secret-init-encryption.enable = false;

        systemd.services.libvirtd.postStart = ''
          ${pkgs.libvirt}/bin/virsh net-info default >/dev/null 2>&1 || \
          ${pkgs.libvirt}/bin/virsh net-define ${pkgs.libvirt}/var/lib/libvirt/qemu/networks/default.xml 2>/dev/null || true
          ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
          ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
        '';
      };
    };
}

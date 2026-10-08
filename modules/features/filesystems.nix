{
  flake.modules.nixos.filesystems =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.ntfs3g
        pkgs.e2fsprogs
      ];
    };
}

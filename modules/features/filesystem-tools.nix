{
  den.aspects.filesystem-tools.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.ntfs3g
        pkgs.e2fsprogs
      ];
    };
}

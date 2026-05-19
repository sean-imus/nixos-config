{ inputs, ... }:
{
  flake-file.inputs = {
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };
  };

  flake.modules.nixos.cachyos-kernel =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.default ];

      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v4;

      nix.settings = {
        substituters = [
          "https://attic.xuyh0120.win/lantian"
        ];
        trusted-public-keys = [
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        ];
      };
    };
}

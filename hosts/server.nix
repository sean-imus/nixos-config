{ pkgs, lib, config, ... }:

{
  imports = [
    ./common.nix
  ];

  networking.hostName = "server";
  system.stateVersion = "25.11";
}

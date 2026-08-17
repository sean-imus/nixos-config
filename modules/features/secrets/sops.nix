{ pkgs, ... }:
{
  home.packages = [ pkgs.sops ];

  home.sessionVariables.SOPS_AGE_KEY_FILE = "/home/sean/.sops/age.key";

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/home/sean/.sops/age.key";
  };
}

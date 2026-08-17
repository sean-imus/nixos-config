{ ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/home/sean/.sops/age.key";
  };
}

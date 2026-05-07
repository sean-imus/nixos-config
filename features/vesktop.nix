{ ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.vesktop = {
      enable = true;
    };
  };
}

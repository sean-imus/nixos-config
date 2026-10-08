{
  flake.modules = {
    nixos.debloat = {
      documentation = {
        doc.enable = false;
        info.enable = false;
        nixos.enable = false;
      };

      programs.nano.enable = false;

      environment.defaultPackages = [ ];
    };

    homeManager.debloat = {
      manual.manpages.enable = false;
    };
  };
}

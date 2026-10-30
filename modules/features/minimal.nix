{
  den.aspects.minimal.nixos = {
    documentation = {
      doc.enable = false;
      info.enable = false;
      nixos.enable = false;
    };

    environment.defaultPackages = [ ];
    programs.nano.enable = false;
    services.speechd.enable = false;
  };
}

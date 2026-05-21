{ ... }: {
  flake.modules.nixos.userDefault = { ... }: { };

  flake.modules.homeManager.userDefault = { ... }: {
    home.stateVersion = "25.11";
  };
}

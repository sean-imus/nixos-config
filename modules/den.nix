{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [ inputs.den.flakeModule ];

  # Every user gets Home Manager, plus the homeManager and user halves of each
  # aspect their host includes, so a feature keeps its nixos, user and
  # homeManager parts side by side no matter whether a host or a user includes it.
  den.schema.user = {
    classes = lib.mkDefault [
      "homeManager"
      "user"
    ];
    includes = [ den.batteries.host-aspects ];
  };
}

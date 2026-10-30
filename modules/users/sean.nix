{ den, ... }:
{
  den.aspects.sean = {
    includes = with den.aspects; [
      den.batteries.define-user
      den.batteries.primary-user
      browser
      claude-code
      comma
      editor
      extra-apps
      git
      shell
      terminal
    ];

    user.hashedPasswordFile = "/home/sean/.secrets/password.txt";

    homeManager = {
      programs.git.settings.user = {
        name = "sean tietz";
        email = "sean.tietz2@gmail.com";
      };

      home.stateVersion = "26.11";
    };
  };
}

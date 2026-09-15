_:
let
  theme = import ../lib/theme.nix;
in
{
  programs = {
    git = {
      enable = true;
      settings.user = {
        name = "sean tietz";
        email = "sean.tietz2@gmail.com";
      };
    };

    lazygit = {
      enable = true;
      settings.gui.theme = {
        activeBorderColor = [
          (theme.hex theme.green)
          "bold"
        ];
        inactiveBorderColor = [ (theme.hex theme.grey0) ];
        optionsTextColor = [ (theme.hex theme.grey2) ];
        selectedLineBgColor = [ (theme.hex theme.bg1) ];
        unstagedChangesColor = [ (theme.hex theme.red) ];
        defaultFgColor = [ (theme.hex theme.fg) ];
        searchingActiveBorderColor = [
          (theme.hex theme.yellow)
          "bold"
        ];
      };
    };
  };

  home.shellAliases = {
    lg = "lazygit";
  };
}

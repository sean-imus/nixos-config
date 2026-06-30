{ ... }:
{
  flake.modules.homeManager.application-launcher =
    { ... }:
    {
      programs.niri.settings.binds."Mod+Space".action.spawn = "fuzzel";

      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            dpi-aware = false;
            namespace = "fuzzel";
            icons-enabled = true;
            sort-result = false;
          };
          colors = {
            background = "2d353bff";
            text = "d3c6aaff";
            prompt = "7a8478ff";
            input = "d3c6aaff";
            match = "a7c080ff";
            selection = "a7c08044";
            selection-text = "d3c6aaff";
            selection-match = "a7c080ff";
            border = "a7c08055";
          };
          border = {
            width = 2;
            radius = 12;
          };
        };
      };
    };
}

{ inputs, pkgs, ... }:
{
  programs.yazi = {
    enable = true;

    flavors.everforest-medium-dark = "${inputs.yazi-everforest}/everforest-medium-dark.yazi";

    theme.flavor.dark = "everforest-medium-dark";

    settings = {
      mgr = {
        sort_by = "natural";
        linemode = "size";
      };
      preview.wrap = "yes";
    };

    keymap = {
      mgr.append_keymap = [
        {
          on = [
            "g"
            "r"
          ];
          run = "cd --interactive";
          desc = "Jump to a path";
        }
        {
          on = [
            "g"
            "d"
          ];
          run = "cd ~/Downloads";
          desc = "Go to Downloads";
        }
        {
          on = [
            "g"
            "n"
          ];
          run = "cd ~/nixos-config";
          desc = "Go to nixos-config";
        }
        {
          on = [
            "g"
            "."
          ];
          run = "cd ~/.config";
          desc = "Go to ~/.config";
        }
      ];
    };

    extraPackages = with pkgs; [
      _7zz
      chafa
      fd
      ffmpeg
      file
      imagemagick
      jq
      poppler-utils
      resvg
      ripgrep
    ];
  };
}

{ ... }:
{
  flake.modules.homeManager.opencode =
    { pkgs, config, lib, ... }:
    {
      home.shellAliases = {
        c = "opencode";
      };

      programs.opencode = {
        enable = true;
        settings = {
          autoupdate = false;
          formatter = true;
          lsp = true;
          mcp = {
            nixos = {
              command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
              enabled = true;
              type = "local";
            };
          };
        };
        tui = {
          theme = "system";
        };
      };

      home.packages = with pkgs; [
        nixd
      ];

      home.activation.mergeOpencodeAuth = lib.hm.dag.entryAfter ["writeBoundary"] ''
        AUTH_KEY_PATH="${config.home.homeDirectory}/.config/opencode/auth_key"
        AUTH_FILE="${config.home.homeDirectory}/.local/share/opencode/auth.json"
        if [ -f "$AUTH_KEY_PATH" ]; then
          API_KEY="$(cat "$AUTH_KEY_PATH")"
          mkdir -p "$(dirname "$AUTH_FILE")"
          ${pkgs.jq}/bin/jq -n --arg key "$API_KEY" \
            '{ "opencode-go": { "type": "api", "key": $key } }' \
            > "$AUTH_FILE.tmp" \
            && mv "$AUTH_FILE.tmp" "$AUTH_FILE"
        fi
      '';
    };
}

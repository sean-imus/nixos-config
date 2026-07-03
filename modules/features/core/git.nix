{ ... }:
{
  flake.modules.homeManager.core =
    { config, lib, ... }:
    {
      programs.git.enable = true;

      sops.secrets.github_token = { };

      programs.gh = {
        enable = true;
        settings.git_protocol = "ssh";
      };

      # gh has no declarative auth option, so write hosts.yml ourselves from the
      # sops-decrypted token. Ordered after sops-nix so the token file exists.
      home.activation.ghAuth = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
        tokenFile="${config.sops.secrets.github_token.path}"
        if [ -f "$tokenFile" ]; then
          token=$(cat "$tokenFile")
          mkdir -p "$HOME/.config/gh"
          printf 'github.com:\n    oauth_token: %s\n    git_protocol: ssh\n    user: sean-imus\n' "$token" \
            | install -m 600 /dev/stdin "$HOME/.config/gh/hosts.yml"
        fi
      '';

      home.shellAliases = {
        lg = "lazygit";
      };

      programs.lazygit = {
        enable = true;
        settings = {
          disableStartupPopups = true;
          gui.theme = {
            activeBorderColor = [
              "#a7c080"
              "bold"
            ];
            inactiveBorderColor = [ "#7a8478" ];
            optionsTextColor = [ "#7fbbb3" ];
            selectedLineBgColor = [ "#3a454a" ];
            unstagedChangesColor = [ "#e67e80" ];
            defaultFgColor = [ "#d3c6aa" ];
            searchingActiveBorderColor = [
              "#dbbc7f"
              "bold"
            ];
          };
        };
      };

      programs.ssh.settings."github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = config.sops.secrets.sean_ssh_id_ed25519.path;
      };

      # Pin GitHub's host key so first-connect never prompts (non-interactive).
      home.file.".ssh/known_hosts" = {
        text = ''
          github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
        '';
        force = true;
      };
    };
}

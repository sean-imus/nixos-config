# Agent Handoff — NixOS Recovery

**Branch:** `claude/nixos-emergency-login-gxsvct`
**Status:** Recovery in progress — reboot pending to validate linger fix

---

## What happened

The notebook was locked out (couldn't log in). Root cause chain:
1. `/persist` was not marked `neededForBoot`, so the sops age key at `/persist/home/sean/.config/sops/age/keys.txt` was unavailable during initrd — NixOS-level sops couldn't decrypt `sean_hashed_password`
2. Home-manager sops secrets also failed: `home-manager-sean.service` runs `Before=systemd-user-sessions.service` (i.e. at boot before the user session exists), so `systemctl restart --user sops-nix` had no user daemon to talk to → secrets never written → `ghAuth` activation crashed reading a missing file

---

## Fixes applied on this branch (all committed, not all pushed)

| Commit | What |
|--------|------|
| `8f60851` | Emergency login: hardcoded `hashedPassword` for sean + root (password: `temprecovery`) |
| `56801f6` | Force `hashedPasswordFile = null` so the hardcoded hash actually takes effect |
| `21b24e8` | `ghAuth` DAG: `entryAfter ["writeBoundary" "sops-nix"]` |
| `47a80f5` | `ghAuth`: wait for sops-nix service + guard `cat` with file existence check (later superseded) |
| `ca51693` | Temporarily disabled HM sops secrets (ssh key + github_token) to unblock HM activation |
| `7e95dc1` | **Real fix #1:** `fileSystems."/persist".neededForBoot = true` — age key available in initrd |
| `0da6a6f` | **Real fix #2:** `users.users.sean.linger = true` — user session starts at boot so HM sops works; re-enabled all HM sops secrets and restored `ghAuth` |

The last commit (`0da6a6f`) is **local only** — couldn't push because gh auth was missing (bootstrapping problem). Push it after the reboot validates everything works.

---

## State after reboot (expected)

If the linger fix worked:
- `loginctl show-user sean | grep Linger` → `Linger=yes`
- `systemctl --user status sops-nix` → active
- `ls ~/.ssh/id_ed25519` → exists (decrypted from sops)
- `ls ~/.config/gh/hosts.yml` → exists (written by ghAuth activation)
- `ls /run/secrets/` → exists (NixOS-level sops working)
- SSH to GitHub works: `ssh -T git@github.com`

---

## What still needs to be done

### 1. Push the local commit
```bash
cd ~/persist/nixos-config
git push -u origin claude/nixos-emergency-login-gxsvct
```

### 2. Revert the emergency login commits
These commits contain a hardcoded password hash in git history and must be removed:
- `8f60851` — added emergency hashedPassword
- `56801f6` — forced hashedPasswordFile to null

The right approach: squash/rebase them out, then force-push the branch (or merge to master without them). The emergency overrides are in `modules/hosts/notebook.nix` lines 6-9.

**Quick revert approach:**
```nix
# In modules/hosts/notebook.nix — remove these 3 lines:
users.users.sean.hashedPasswordFile = lib.mkForce null;
users.users.sean.hashedPassword = lib.mkForce "...";
users.users.root.hashedPassword = "...";

# Also remove lib from the module args if nothing else uses it:
{ lib, pkgs, ... }  →  { pkgs, ... }
```
After removing, rebuild and verify login still works via sops (which now works correctly with the neededForBoot + linger fixes).

### 3. Merge to master
Once emergency overrides are gone and everything is verified working.

---

## Key files

| File | What's in it |
|------|-------------|
| `modules/hosts/notebook.nix` | Emergency login overrides (REVERT), linger not here |
| `modules/users/sean.nix` | `linger = true` added here |
| `modules/features/storage/disko.nix` | `neededForBoot = true` for `/persist` |
| `modules/features/secrets/sops.nix` | HM sops config — age key path, `sean_ssh_id_ed25519` secret |
| `modules/features/dev/git.nix` | `github_token` secret + `ghAuth` activation |
| `modules/features/secrets/secrets.yaml` | Encrypted secrets (age recipient: `age1kg6ly5j5f6ynj82k3yuthpqyzegzkr0y07jz2n5g30wve5utzees4y3wwh`) |

---

## If linger fix did NOT work after reboot

Check:
```bash
journalctl -b --no-pager -u home-manager-sean.service
systemctl --user status sops-nix
loginctl show-user sean | grep Linger
```

If `home-manager-sean.service` still fails on sops: the alternative is to make the HM sops activation synchronous by changing the sops-nix HM module approach, or to add `home-manager-sean.service` ordering after `graphical-session.target`. File a note here and continue debugging.

{
  inputs,
  pkgs,
  ...
}:
# sops-nix quick reference
# ========================
#
# Mental model: `.sops.yaml` at the repo root is a routing table that maps file
# paths to a set of age *public* keys (recipients). When a secret is created or
# updated, sops encrypts it to every recipient. Each recipient decrypts with
# their matching *private* key. Public keys are safe to commit.
#
# Who holds which private key:
#   - Each host: derived from /etc/ssh/ssh_host_ed25519_key (see below).
#   - Each user: ~/.config/sops/age/keys.txt (usually derived from ~/.ssh/id_ed25519).
#
# -----------------------------------------------------------------------------
# First-time setup on a new workstation (so *you* can edit secrets):
#
#   mkdir -p ~/.config/sops/age
#   nix-shell -p ssh-to-age --run \
#     'ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt'
#   chmod 600 ~/.config/sops/age/keys.txt
#
# -----------------------------------------------------------------------------
# Adding a new host as a recipient (so the host can decrypt at activation):
#
#   1. Get its age pubkey:
#        ssh <host> 'cat /etc/ssh/ssh_host_ed25519_key.pub' \
#          | nix-shell -p ssh-to-age --run 'ssh-to-age'
#
#   2. Add to .sops.yaml under `keys:` with an anchor, e.g.
#        - &host_trident age1xxxxx...
#      and include it in the relevant `creation_rules[].key_groups[].age` list.
#
#   3. Re-encrypt *existing* secrets that should include the new host:
#        sops updatekeys secrets/<path>/<file>.yaml
#      (.sops.yaml changes only affect files created *after* the change.)
#
# -----------------------------------------------------------------------------
# Adding a new user as a recipient (so another person can edit):
#
#   Same as above, but their pubkey comes from their own age key or SSH key:
#     ssh-to-age < their_id_ed25519.pub
#
# -----------------------------------------------------------------------------
# Creating or editing a secret:
#
#   sops secrets/<host>/<name>.yaml
#
# The file must exist in git (or at least be tracked by a dirty worktree) before
# `nixos-rebuild` will see it — flakes don't pick up untracked new paths.
#
# -----------------------------------------------------------------------------
# Using a secret in a NixOS module:
#
#   sops.secrets."my-secret" = {
#     sopsFile = ../../secrets/<host>/<name>.yaml;
#     mode = "0400";
#     owner = "root";
#   };
#   # Reference at runtime:
#   #   config.sops.secrets."my-secret".path  →  /run/secrets/my-secret
#
# -----------------------------------------------------------------------------
# Gotchas:
#   - If /etc/ssh/ssh_host_ed25519_key is regenerated (reinstall, new host), the
#     host's age identity changes and it loses access to existing secrets.
#     Either preserve the host key across reinstalls, or re-encrypt with
#     `sops updatekeys` from a workstation that still has access.
#   - Activation fails loudly if a host can't decrypt a secret it references —
#     that's a feature, not a bug.
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = [ pkgs.sops pkgs.age pkgs.ssh-to-age ];

  # Derive host age key from the system's SSH host key.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}

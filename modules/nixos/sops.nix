{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = [ pkgs.sops pkgs.age pkgs.ssh-to-age ];

  # Derive host age key from the system's SSH host key.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}

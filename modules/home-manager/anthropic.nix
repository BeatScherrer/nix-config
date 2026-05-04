{ config, inputs, ... }:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets."anthropic-api-key" = {
      sopsFile = ../../secrets/anthropic.yaml;
    };
  };

  programs.bash.bashrcExtra = ''
    if [[ -r ${config.sops.secrets."anthropic-api-key".path} ]]; then
      export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets."anthropic-api-key".path})"
    fi
  '';
}

{ config, inputs, ... }:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets."mistral-api-key" = {
      sopsFile = ../../secrets/mistral.yaml;
    };
  };

  programs.bash.bashrcExtra = ''
    if [[ -r ${config.sops.secrets."mistral-api-key".path} ]]; then
      export MISTRAL_API_KEY="$(cat ${config.sops.secrets."mistral-api-key".path})"
    fi
  '';
}

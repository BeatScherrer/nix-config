{ config, inputs, ... }:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets."openrouter-api-key" = {
      sopsFile = ../../secrets/openrouter.yaml;
    };
  };

  programs.bash.bashrcExtra = ''
    if [[ -r ${config.sops.secrets."openrouter-api-key".path} ]]; then
      export OPENROUTER_API_KEY="$(cat ${config.sops.secrets."openrouter-api-key".path})"
    fi
  '';
}

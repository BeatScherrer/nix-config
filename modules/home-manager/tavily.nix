{ config, inputs, ... }:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets."tavily-api-key" = {
      sopsFile = ../../secrets/tavily.yaml;
    };
  };

  programs.bash.bashrcExtra = ''
    if [[ -r ${config.sops.secrets."tavily-api-key".path} ]]; then
      export TAVILY_API_KEY="$(cat ${config.sops.secrets."tavily-api-key".path})"
    fi
  '';
}

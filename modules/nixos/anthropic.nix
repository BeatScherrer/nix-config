{ config, ... }:
{
  sops.secrets."anthropic-api-key" = {
    sopsFile = ../../secrets/anthropic.yaml;
    mode = "0400";
    owner = "beat";
    group = "beat";
  };

  environment.extraInit = ''
    if [ -r ${config.sops.secrets."anthropic-api-key".path} ]; then
      export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets."anthropic-api-key".path})"
    fi
  '';
}

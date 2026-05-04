{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm; # AMD GPU; alternatives: ollama, ollama-cuda, ollama-vulkan, ollama-cpu
    # Listen on all interfaces so the API is reachable from the tailnet.
    # Firewall already trusts tailscale0 (modules/nixos/tailscale.nix), so this
    # is not exposed to the public internet.
    host = "0.0.0.0";
    port = 11434;
    # loadModels = [ "qwen3.6:35b-a3b" ];
  };
}

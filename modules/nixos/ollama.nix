{ ... }:
{
  services.ollama = {
    enable = true;
    # loadModels = [ ... ]
    acceleration = "rocm"; # NOTE: 'rocm': ADM, 'cuda': nvidia
  };
}

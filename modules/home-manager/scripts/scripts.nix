{ pkgs, ... }:
let 
  mkScript = name: file: pkgs.writeShellScriptBin name(builtins.readFile ./scripts/${file});
in
{
  # TODO: copy scripts to ~/.local/bin
  home.packages = [
    (mkScript "nix-switch-generation" "nix-switch-generation.bash")

  ];
}

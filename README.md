# Nix Config

## Build
To build the nixos packages:

```
sudo nixos-rebuild test --flake ~/.nix#default
sudo nixos-rebuild switch --flake ~/.nix#default
```

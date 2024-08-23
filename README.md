# Nix Config

## Build
To build the nixos packages:

```
sudo nixos-rebuild test --flake ~/.nix#default
sudo nixos-rebuild switch --flake ~/.nix#default
```

## Debug builds
```
nix repl
> :lf .
```

and then tab-complete...

the most common attributes:
```
inputs
outputs
```

# Nix Config

## Build
To build the nixos packages:

```
sudo nixos-rebuild test --flake ~/.nix#default
sudo nixos-rebuild switch --flake ~/.nix#default
```


# Build for darwin

to build for a darwin host with name `hostname` use the following command or create an alias for it:
```
nix build .#darwinConfigurations.hostname.system --extra-experimental-features 'nix-command flakes'
./result/sw/bin/darwin-rebuild switch --flake .#hostname
```

# Home-manager

TODO

# Debug

## Flakes

### List outputs:
`nix flake show`

### Show attributes
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



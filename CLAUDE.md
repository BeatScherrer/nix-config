# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive NixOS/Darwin configuration repository using Nix Flakes. It manages system and user configurations for multiple hosts across Linux and macOS platforms with a modular architecture.

## Build Commands

### NixOS (Linux Systems)
```bash
# Test configuration without switching
sudo nixos-rebuild test --flake ~/.nix#default

# Apply configuration
sudo nixos-rebuild switch --flake ~/.nix#default
```

### Darwin (macOS Systems) 
```bash
# Build and apply (replace 'hostname' with actual host name)
nix build .#darwinConfigurations.hostname.system --extra-experimental-features 'nix-command flakes'
./result/sw/bin/darwin-rebuild switch --flake .#hostname
```

### Development Environment
```bash
# Enter development shell (automatic via direnv if .envrc present)
nix develop

# Show flake outputs
nix flake show

# Interactive debugging
nix repl
# Then in repl: :lf . 
# Tab-complete to explore: inputs, outputs
```

### Flake Updates
```bash
# Update all inputs
nix flake update

# Update single input
nix flake lock --update-input nixpkgs

# Update specific stable channel
nix flake lock --update-input nixpkgs-stable
```

### Convenient Aliases
Shell aliases are configured for common operations:
- `nixupdate`: `sudo nixos-rebuild switch --flake ~/.nix`
- `nixtest`: `sudo nixos-rebuild test --flake ~/.nix` 
- `homeupdate`: `home-manager switch --flake ~/.nix` (for standalone Home Manager)

## Architecture Overview

### Multi-Host Configuration
- **trident**: Desktop Linux system (AMD GPU, gaming setup)
- **legion**: Laptop Linux system
- **obsidian**: macOS system
- Cross-platform support for x86_64 and aarch64 architectures

### Module Structure

#### System Modules (`modules/nixos/`)
- `user.nix`: User account configuration
- `nix.nix`: Nix daemon settings and garbage collection
- `herbstluftwm.nix`: Tiling window manager configuration
- `sound.nix`: Audio system configuration
- `games.nix`: Gaming packages (Steam, etc.)
- `container/`: Podman/Docker setup
- `mtr/`: Work-specific VPN and SSH configuration

#### User Modules (`modules/home-manager/`)
- `shell/`: Bash/Zsh with custom themes and aliases
- `polybar/`: Status bar with custom scripts and widgets
- `rofi/`: Application launcher with themes
- `herbstluftwm/`: Window manager layouts and key bindings
- `git/`: Git configuration with commit hooks
- `color-scheme/`: Consistent theming across applications
- `ghostty/`: Terminal emulator configuration
- `vscode/`: VS Code settings and extensions

### Key Configuration Files
- `flake.nix`: Main flake defining inputs, outputs, and host configurations
- `hosts/*/configuration.nix`: Host-specific system configurations
- `hosts/*/home.nix`: Host-specific Home Manager configurations
- `home-manager/home.nix`: Base Home Manager configuration
- `home-manager/home-darwin.nix`: macOS-specific user configuration

## Development Notes

### Flakes Workflow
- All configurations use Nix Flakes for reproducibility
- `flake.lock` should be committed to maintain version consistency
- Development shell includes nixd LSP and nixfmt-rfc-style formatter
- `patches/` directory contains custom patches applied to nixpkgs (e.g., nvidia-ctk.patch for Legion host)

### Module System
- Custom modules are defined in `modules/` with configurable options
- Host-specific overrides are applied in `hosts/*/` directories
- Home Manager configurations are separate but integrated

### Common Tasks
- When modifying system configuration, test first with `nixos-rebuild test`
- Home Manager changes can be tested independently if needed
- Use `nix flake show` to understand available outputs
- Git hooks are configured to format commit messages

### Theming System
- Color schemes are centrally managed in `modules/home-manager/color-scheme/`
- Wallpapers and fonts are version-controlled
- Consistent theming across polybar, rofi, terminal, and other applications

## Host-Specific Considerations

### Trident (Desktop)
- AMD GPU configuration with gaming optimizations
- HerbstluftWM with multi-monitor support
- Containerization enabled for development and gaming

### Legion (Laptop)
- Portable configuration with power management
- Similar software stack adapted for mobile use

### Obsidian (macOS)
- Darwin-specific configurations
- Cross-platform module compatibility where possible
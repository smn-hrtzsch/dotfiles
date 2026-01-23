# AGENTS.md - Dotfiles Repository

This document provides guidance for AI coding agents working with this dotfiles repository.

## Project Overview

Personal dotfiles and system configuration repository using **Nix** for declarative,
reproducible system management. Supports **macOS (Apple Silicon)** and **Windows (WSL 2)**.

**Primary Language:** Nix (configuration), Bash/Zsh (scripts), Lua (WezTerm config)

## Repository Structure

```
dotfiles/
├── nix/                    # Core Nix configurations (MAIN ENTRY POINT)
│   ├── flake.nix           # Flake definition - system entry point
│   ├── home.nix            # Shared Home Manager config (packages, programs)
│   └── darwin-configuration.nix  # macOS-specific settings
├── zsh/                    # Zsh configuration
│   ├── .zshrc              # Main shell config
│   └── config/             # Modular configs (aliases.zsh, exports.zsh, functions.zsh)
├── config/.config/         # Application configs (ghostty, opencode, gh, etc.)
├── scripts/                # Setup and utility scripts
├── macos/                  # macOS-specific files (wallpaper, hotkeys)
├── windows/                # Windows-specific files (packages.json)
└── opencode/.opencode/     # OpenCode AI commands
```

## Build & Apply Commands

### Apply Configuration Changes

```bash
# macOS (uses nix-darwin)
darwin-rebuild switch --flake ~/dotfiles/nix

# WSL/Linux (uses home-manager)
home-manager switch --flake ~/dotfiles/nix#wsl

# Shortcut (works on both platforms)
rebuild
```

### Validate Configuration

```bash
# Check flake syntax (run from repo root)
nix flake check ./nix

# Build without activating (dry run)
# macOS:
nix build ./nix#darwinConfigurations.MacBook-Air-von-Simon.system
# WSL:
nix build ./nix#homeConfigurations.wsl.activationPackage
```

### Update Dependencies

```bash
# Update flake lock file
nix flake update ./nix

# Full system update (pulls git changes + rebuilds)
update-system
```

## Testing

This repository has no formal test suite. Validation is done through:

1. **CI Pipeline** (`.github/workflows/nix-check.yml`): Runs on `chore/nix-migration` branch
   - Checks flake syntax
   - Builds macOS Darwin configuration
   - Builds WSL home configuration

2. **Manual Testing**: Apply changes and verify system behavior

## Code Style Guidelines

### Nix Files

- **Formatting**: Use 2-space indentation
- **Attribute Sets**: One attribute per line for readability
- **Comments**: Use `#` for inline comments
- **Lists**: Use `with pkgs;` pattern for package lists
- **Conditionals**: Use `if pkgs.stdenv.isDarwin then [...] else [...]` for platform-specific logic
- **Imports**: Use relative paths (`./home.nix`, `./darwin-configuration.nix`)

```nix
# Example style
{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    eza
    zoxide
    fzf
  ] ++ (if pkgs.stdenv.isDarwin then [
    pkgs.dockutil
  ] else [
    pkgs.wslu
  ]);
}
```

### Shell Scripts (Bash/Zsh)

- **Shebang**: Use `#!/bin/bash` or `#!/usr/bin/env zsh`
- **Indentation**: 2 spaces
- **Quoting**: Always quote variables: `"$variable"`
- **Conditionals**: Use `[[ ]]` for tests (not `[ ]`)
- **Platform Detection**: Use `[[ "$(uname)" == "Darwin" ]]` for macOS
- **Error Handling**: Check command success with `if [ $? -ne 0 ]` or `|| return 1`
- **Comments**: German or English; be consistent within a file
- **Functions**: Use `function_name() { }` syntax

```bash
# Example function
update-system() {
  local DOTFILES="$HOME/dotfiles"
  if [[ "$(uname)" == "Darwin" ]]; then
    darwin-rebuild switch --flake ./nix
  else
    home-manager switch --flake ./nix#wsl
  fi
}
```

### Git Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- **Language**: English, concise
- **Examples**:
  - `feat(nix): add nodejs_22 to home packages`
  - `fix(zsh): correct ANDROID_HOME path for WSL`
  - `chore(darwin): update homebrew casks`

## Key Configuration Patterns

### Adding New Packages

1. **CLI Tools**: Add to `nix/home.nix` under `home.packages`
2. **macOS GUI Apps**: Add to `nix/darwin-configuration.nix` under `homebrew.casks`
3. **Mac App Store**: Add to `homebrew.masApps` with app ID
4. **npm Global**: Add to `npm/npm-globals.txt`

### Adding New Dotfile Symlinks

Edit `nix/home.nix` under `home.file`:

```nix
home.file = {
  ".config/myapp".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/myapp";
};
```

### Platform-Specific Configuration

```nix
# In home.nix - conditional packages
] ++ (if pkgs.stdenv.isDarwin then [ ... ] else [ ... ]);

# In home.nix - conditional file symlinks
} // (if pkgs.stdenv.isDarwin then { ... } else {});
```

## Environment Variables

Key variables set in `zsh/config/exports.zsh`:

- `EDITOR="code --wait"` - Default editor
- `ANDROID_HOME` - Platform-specific Android SDK path
- `JAVA_HOME` - Platform-specific Java path
- `DOTNET_ROOT` - .NET SDK location

## Important Notes

- **Never commit secrets** - Use `~/.zshrc_secrets` for sensitive exports
- **Nix preferred** - When installing tools, prefer adding to Nix config over manual install
- **Test on both platforms** - Changes to `home.nix` affect both macOS and WSL
- **CI runs on branch** - Currently only triggers on `chore/nix-migration` branch
- **shellcheck available** - Use for linting shell scripts (`shellcheck script.sh`)

## Useful Aliases

```bash
rebuild     # Apply nix configuration
ls          # eza with icons (aliased)
cd          # zoxide (aliased)
gits        # git status
ga.         # git add .
gc "msg"    # git commit -m "msg"
```

## OpenCode Commands

Custom commands in `opencode/.opencode/commands/`:

- `/commit` - Generate and execute conventional commit
- `/review` - Code review
- `/plan`, `/execute` - Task planning and execution

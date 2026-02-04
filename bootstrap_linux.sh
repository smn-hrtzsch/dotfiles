#!/bin/bash

# bootstrap_linux.sh - Generic Linux Dotfiles Bootstrap

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Starting Bootstrap for Generic Linux Dotfiles Setup (Nix Edition)...${NC}"

# --- 1. Dependencies Check ---
echo -e "${BLUE}>>> 1. Checking dependencies...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}   Git not found. Installing git...${NC}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm git
    else
        echo -e "${RED}   Package manager not found. Please install git manually.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}   ✓ Git found.${NC}"
fi

if ! command -v curl &> /dev/null; then
    echo -e "${RED}   Curl not found. Please install curl manually.${NC}"
    exit 1
fi

# --- 2. Nix Installation ---
echo -e "${BLUE}>>> 2. Checking Nix installation...${NC}"
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}   Nix not found. Installing Nix (Determinate Systems)...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Load Nix for this session
    if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
else
    echo -e "${GREEN}   ✓ Nix already installed.${NC}"
fi

# --- 3. Clone Repository ---
REPO_DIR="$HOME/dotfiles"
echo -e "${BLUE}>>> 3. Setting up Dotfiles Repo...${NC}"

if [ ! -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}   Cloning repository...${NC}"
    git clone https://github.com/smn-hrtzsch/dotfiles.git "$REPO_DIR"
    cd "$REPO_DIR"
    
    # Check out the correct branch (for now, feat/linux-support, later main)
    # git checkout feat/linux-support
else
    echo -e "${GREEN}   ✓ Repository already exists.${NC}"
    cd "$REPO_DIR"
fi

# --- 4. User Configuration ---
echo -e "${BLUE}>>> 4. User Configuration...${NC}"
echo -e "${YELLOW}   We need to configure the flake for your user.${NC}"

# Default values from the file
DEFAULT_USER="simon"
DEFAULT_GIT_NAME="Simon Hörtzsch"
DEFAULT_GIT_EMAIL="simon@hoertzsch.de"

read -p "   Enter your username (default: $USER): " INPUT_USER
INPUT_USER=${INPUT_USER:-$USER}

read -p "   Enter your Git Name (default: Generic User): " INPUT_GIT_NAME
INPUT_GIT_NAME=${INPUT_GIT_NAME:-"Generic User"}

read -p "   Enter your Git Email (default: user@example.com): " INPUT_GIT_EMAIL
INPUT_GIT_EMAIL=${INPUT_GIT_EMAIL:-"user@example.com"}

echo -e "${BLUE}   Updating nix/flake.nix with your details...${NC}"

# Update flake.nix using sed (Linux syntax)
sed -i "s/username = \"$DEFAULT_USER\";/username = \"$INPUT_USER\";/" nix/flake.nix
sed -i "s/gitUserName = \"$DEFAULT_GIT_NAME\";/gitUserName = \"$INPUT_GIT_NAME\";/" nix/flake.nix
sed -i "s/gitUserEmail = \"$DEFAULT_GIT_EMAIL\";/gitUserEmail = \"$INPUT_GIT_EMAIL\";/" nix/flake.nix

echo -e "${GREEN}   ✓ Configuration updated.${NC}"

# --- 4.5 SSH Key Setup ---
echo -e "${BLUE}>>> 4.5. Checking SSH Key Configuration...${NC}"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo -e "${YELLOW}   No SSH key found. Generating a new one for GitHub...${NC}"
    echo -e "${YELLOW}   Using email: $INPUT_GIT_EMAIL${NC}"
    
    # Ensure .ssh directory exists
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Generate Key
    ssh-keygen -t ed25519 -C "$INPUT_GIT_EMAIL" -f "$SSH_KEY_PATH"
    
    # Start ssh-agent and add key
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY_PATH"
    
    echo -e "${GREEN}   ✓ SSH Key generated.${NC}"
    echo -e "\n${YELLOW}   PLEASE ADD THE FOLLOWING PUBLIC KEY TO GITHUB:${NC}"
    echo -e "${YELLOW}   https://github.com/settings/ssh/new${NC}\n"
    echo -e "${BLUE}----------------------------------------------------------------------${NC}"
    cat "$SSH_KEY_PATH.pub"
    echo -e "${BLUE}----------------------------------------------------------------------${NC}"
    echo -e "\n"
    echo -e "${YELLOW}   Press [ENTER] once you have added the key to GitHub...${NC}"
    read -r
    
    # Optional: Switch remote to SSH if desired
    echo -e "${YELLOW}   Would you like to switch the cloned repo to use SSH instead of HTTPS? (y/n)${NC}"
    read -r -p "   > " SWITCH_SSH
    if [[ "$SWITCH_SSH" =~ ^[Yy]$ ]]; then
        git remote set-url origin "git@github.com:smn-hrtzsch/dotfiles.git"
        echo -e "${GREEN}   ✓ Remote URL changed to SSH.${NC}"
    fi
else
    echo -e "${GREEN}   ✓ SSH Key already exists. Skipping generation.${NC}"
fi

# --- 5. Apply Configuration ---
echo -e "${BLUE}>>> 5. Applying Nix Configuration (Home Manager)...${NC}"

# Detect Architecture
ARCH=$(uname -m)
FLAKE_ATTR=""

if [[ "$ARCH" == "x86_64" ]]; then
    FLAKE_ATTR="linux-x86_64"
    echo -e "${GREEN}   Detected x86_64 architecture.${NC}"
elif [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    FLAKE_ATTR="linux-aarch64"
    echo -e "${GREEN}   Detected ARM64 architecture.${NC}"
else
    echo -e "${RED}   Unsupported architecture: $ARCH. Please check nix/flake.nix.${NC}"
    exit 1
fi

# Run Home Manager via nix run
echo -e "${BLUE}   Building configuration for ${FLAKE_ATTR}...${NC}"
nix run home-manager/master -- switch --flake ./nix#${FLAKE_ATTR}

# --- 6. Set Default Shell ---
echo -e "${BLUE}>>> 6. Configuring Shell...${NC}"
if [[ "$SHELL" != *zsh* ]]; then
    echo -e "${YELLOW}   Changing default shell to zsh...${NC}"
    # Use chsh to set zsh (which should be in /home/user/.nix-profile/bin/zsh or /bin/zsh)
    # We prefer the nix installed one if available
    ZSH_PATH=$(which zsh)
    if grep -q "$ZSH_PATH" /etc/shells; then
        chsh -s "$ZSH_PATH"
    else
        echo -e "${YELLOW}   Adding $ZSH_PATH to /etc/shells (requires sudo)...${NC}"
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
        chsh -s "$ZSH_PATH"
    fi
    echo -e "${GREEN}   ✓ Shell changed to Zsh.${NC}"
else
    echo -e "${GREEN}   ✓ Zsh is already the default shell.${NC}"
fi

echo -e "${GREEN}>>> Bootstrap completed successfully! 🚀${NC}"
echo -e "${GREEN}>>> Please restart your shell.${NC}"

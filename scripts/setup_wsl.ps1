<#
.SYNOPSIS
    Automated Setup for a Nix-based WSL2 Environment (Ubuntu 24.04).

.DESCRIPTION
    1. Downloads Ubuntu 24.04 Cloud Image.
    2. Imports it into WSL as a new Distro (default: Ubuntu-Nix).
    3. Creates a default user.
    4. Prepares a bootstrap script inside the distro to install Nix & Dotfiles.

.PARAMETER DistroName
    Name of the WSL Distro (Default: Ubuntu-Nix)

.PARAMETER InstallPath
    Path where the VHDX will be stored (Default: C:\WSL\<DistroName>)

.PARAMETER Branch
    Dotfiles git branch to use (Default: main)

.PARAMETER LinuxUser
    Linux username to create inside the WSL distro (Default: current Windows username)

.PARAMETER LinuxPassword
    Linux user password (Default: same as LinuxUser)
#>

param (
    [string]$DistroName = "Ubuntu-Nix",
    [string]$InstallPath = "C:\WSL",
    [string]$Branch = "main",
    [string]$LinuxUser = $env:USERNAME,
    [string]$LinuxPassword = $null
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($LinuxUser)) {
    $LinuxUser = "user"
}

$LinuxUser = $LinuxUser.ToLower() -replace "[^a-z0-9_-]", ""
if ([string]::IsNullOrWhiteSpace($LinuxUser)) {
    $LinuxUser = "user"
}

if ([string]::IsNullOrWhiteSpace($LinuxPassword)) {
    $LinuxPassword = $LinuxUser
}
$UbuntuUrl = "https://cloud-images.ubuntu.com/wsl/releases/24.04/current/ubuntu-noble-wsl-amd64-24.04lts.rootfs.tar.gz"
$ImageFile = "$InstallPath\ubuntu-noble-wsl.tar.gz"
$DistroPath = "$InstallPath\$DistroName"

# 1. Prepare Directory
if (-not (Test-Path $DistroPath)) {
    Write-Host "Creating directory: $DistroPath" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $DistroPath | Out-Null
}

# 2. Download Image
if (-not (Test-Path $ImageFile)) {
    Write-Host "Downloading Ubuntu 24.04 Image..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $UbuntuUrl -OutFile $ImageFile -UseBasicParsing
} else {
    Write-Host "Using existing image: $ImageFile" -ForegroundColor Green
}

# 3. Import Distro
Write-Host "Importing Distro '$DistroName'..." -ForegroundColor Cyan
if (wsl --list --quiet | Select-String -Pattern $DistroName) {
    Write-Warning "Distro '$DistroName' already exists. Skipping import."
} else {
    wsl --import $DistroName $DistroPath $ImageFile
}

# 4. Configure User & Basics
Write-Host "Configuring User '$LinuxUser'..." -ForegroundColor Cyan
$SetupScript = @'
echo "Creating user __USER__..."
id -u __USER__ &>/dev/null || useradd -m -s /bin/bash __USER__
echo "__USER__:__PASSWORD__" | chpasswd
usermod -aG sudo __USER__

echo 'Installing dependencies...'
apt-get update && apt-get install -y curl git xz-utils

echo "Configuring wsl.conf..."
cat <<EOF > /etc/wsl.conf
[user]
default=__USER__
[boot]
systemd=true
EOF

echo "Creating user bootstrap script..."
cat <<'EOS' > /home/__USER__/finish_setup.sh
#!/bin/bash
set -e

echo "🚀 Starting Nix Installation..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

echo "🔄 Loading Nix Environment..."
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "🔑 SSH Key Generation..."
if [ ! -f ~/.ssh/id_ed25519 ]; then
    read -p "Git Email (default: __USER__@example.com): " GIT_EMAIL
    GIT_EMAIL=${GIT_EMAIL:-__USER__@example.com}
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N ""
fi

echo ""
echo "========================================================"
echo "🛑 ACTION REQUIRED: Add this key to GitHub:"
echo "https://github.com/settings/ssh/new"
echo "========================================================"
cat ~/.ssh/id_ed25519.pub
echo "========================================================"
echo ""
read -p "Press ENTER after you have added the key to GitHub..."

echo "📥 Cloning Dotfiles (__BRANCH__)..."
if [ -d ~/dotfiles ]; then
    echo "Dotfiles already exist. Pulling..."
    cd ~/dotfiles && git pull
else
    git clone git@github.com:smn-hrtzsch/dotfiles.git ~/dotfiles
fi

cd ~/dotfiles
git fetch origin "__BRANCH__" || true
git checkout "__BRANCH__" || git checkout -b "__BRANCH__" "origin/__BRANCH__" || true
git submodule update --init --recursive

echo "⚙️ Applying Nix Configuration..."
cd ~/dotfiles
# Ensure we are on the right branch/flake
# git checkout __BRANCH__
ARCH=$(uname -m)
TARGET="wsl"
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
  TARGET="wsl-aarch64"
fi
nix run home-manager/master -- switch --flake ./nix#$TARGET

echo "✅ Setup Complete! Please restart your shell."
EOS

chown __USER__:__USER__ /home/__USER__/finish_setup.sh
chmod +x /home/__USER__/finish_setup.sh
'@

$SetupScript = $SetupScript.Replace("__USER__", $LinuxUser)
$SetupScript = $SetupScript.Replace("__PASSWORD__", $LinuxPassword)
$SetupScript = $SetupScript.Replace("__BRANCH__", $Branch)

# Inject script via stdin to avoid path issues
$SetupScript | wsl -d $DistroName -u root --exec bash

# 5. Configure WezTerm (Windows Side)
Write-Host "Linking WezTerm Config..." -ForegroundColor Cyan
$WezTermConfigDir = "$env:USERPROFILE\.config\wezterm"
$WezTermConfigFile = "$WezTermConfigDir\wezterm.lua"
$WSLConfigPath = "\\wsl.localhost\$DistroName\home\$LinuxUser\.config\wezterm\wezterm.lua"

if (-not (Test-Path $WezTermConfigDir)) {
    New-Item -ItemType Directory -Force -Path $WezTermConfigDir | Out-Null
}

if (Test-Path $WezTermConfigFile) {
    if ((Get-Item $WezTermConfigFile).LinkType -ne "SymbolicLink") {
        Write-Warning "Existing WezTerm config found. Backing up to wezterm.lua.bak"
        Rename-Item -Path $WezTermConfigFile -NewName "wezterm.lua.bak" -Force
    } else {
        # Remove existing link to ensure we point to the new distro
        Remove-Item -Path $WezTermConfigFile -Force
    }
}

# Create Symlink
try {
    # Note: Target needs to be a global path accessible by Windows
    New-Item -ItemType SymbolicLink -Path $WezTermConfigFile -Target $WSLConfigPath | Out-Null
    Write-Host "✅ WezTerm linked to WSL config!" -ForegroundColor Green
} catch {
    Write-Warning "Could not create WezTerm symlink. You might need Developer Mode enabled or Run as Admin."
    Write-Warning "Manual Command: New-Item -ItemType SymbolicLink -Path $WezTermConfigFile -Target $WSLConfigPath"
}

Write-Host "----------------------------------------------------------------" -ForegroundColor Green
Write-Host "✅ Base Setup Complete!" -ForegroundColor Green
Write-Host "----------------------------------------------------------------"
Write-Host "1. Open the Distro: wsl -d $DistroName"
Write-Host "2. Run the finish script: ./finish_setup.sh"
Write-Host "----------------------------------------------------------------"
Write-Host "⚠️  IMPORTANT: Ensure 'MesloLGS NF' font is installed in Windows!"
Write-Host "   Download: https://github.com/romkatv/powerlevel10k#manual-font-installation"
Write-Host "----------------------------------------------------------------"

#!/usr/bin/env bash

# setup_android.sh - Configures Linux Android SDK for WSL compatibility
# This script should be run after nix/home-manager is set up.

set -e

echo "Starting Android SDK setup for WSL..."

# 1. Ensure we are on Linux
if [[ "$(uname)" != "Linux" ]]; then
    echo "This script is intended for Linux/WSL only."
    exit 1
fi

# 2. Define Paths
ANDROID_HOME="$HOME/Android/Sdk"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

# 3. Create directory structure
mkdir -p "$ANDROID_HOME/cmdline-tools"

# 4. Download and Install Command Line Tools if missing

if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then

    echo "Downloading Android Command Line Tools..."

    TEMP_DIR=$(mktemp -d)

    curl -L -s -o "$TEMP_DIR/cmdline-tools.zip" "$CMDLINE_TOOLS_URL"

    

    echo "Extracting tools..."

    unzip -q "$TEMP_DIR/cmdline-tools.zip" -d "$TEMP_DIR"

    

    mkdir -p "$ANDROID_HOME/cmdline-tools/latest"

    cp -r "$TEMP_DIR/cmdline-tools/"* "$ANDROID_HOME/cmdline-tools/latest/"

    

    rm -rf "$TEMP_DIR"

    echo "Command Line Tools installed."

    

    echo ""

    echo "==========================================================" 

    echo "ACTION REQUIRED: Please accept the Android SDK licenses:"

    echo "Run: source ~/.zshrc && yes | sdkmanager --licenses"

    echo ""

    echo "After that, install required build-tools:"

    echo "Run: sdkmanager \"platform-tools\" \"platforms;android-35\" \"build-tools;35.0.0\""

    echo "=========================================================="

fi

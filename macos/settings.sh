#!/bin/bash

# macOS Settings Script
# Sets reasonable defaults for a developer machine.
# Run this script after setting up the machine.

echo ">>> Applying macOS settings..."

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# --- Finder ---
echo "   Configuring Finder..."
# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- Dock ---
echo "   Configuring Dock..."
# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# Autohide the Dock
defaults write com.apple.dock autohide -bool true

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# --- Keyboard ---
echo "   Configuring Keyboard..."
# Fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# --- Screenshots ---
echo "   Configuring Screenshots..."
# Save screenshots to the Desktop/Screenshots folder
mkdir -p "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Desktop/Screenshots"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# --- Text Editing ---
echo "   Configuring Text Editing..."
# Disable smart quotes and dashes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# --- Restarting Apps ---
echo "   Restarting affected applications..."
for app in "Dock" "Finder" "SystemUIServer"; do
    killall "${app}" &> /dev/null
done

echo ">>> macOS settings applied!"

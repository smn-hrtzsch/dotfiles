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

# Keep folders on top when sorting by name (User preference: false)
defaults write com.apple.finder _FXSortFoldersFirst -bool false

# Set list view as preferred view style
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- Appearance ---
echo "   Configuring Appearance..."
# Dark Mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Set Wallpaper
WALLPAPER_PATH="${HOME}/dotfiles/macos/wallpaper.jpg"
if [ -f "$WALLPAPER_PATH" ]; then
    echo "   Setting wallpaper..."
    osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$WALLPAPER_PATH\""
else
    echo "   Warning: Wallpaper not found at $WALLPAPER_PATH"
fi

# --- Dock ---
echo "   Configuring Dock..."
# Set the icon size of Dock items to 39 pixels
defaults write com.apple.dock tilesize -int 39

# Autohide the Dock
defaults write com.apple.dock autohide -bool true
# Remove the autohide delay (make it instant)
defaults write com.apple.dock autohide-delay -float 0

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Configure Dock Icons
if command -v dockutil &> /dev/null; then
    echo "   Setting up Dock icons..."
    dockutil --no-restart --remove all

    # Function to add app if it exists
    add_dock_app() {
        if [ -e "$1" ]; then
            dockutil --no-restart --add "$1"
        else
            echo "   Skipping missing app: $1"
        fi
    }

    add_dock_app "/Applications/Brave Browser.app"
    add_dock_app "/Applications/Ghostty.app"
    add_dock_app "/Applications/Notion.app"
    add_dock_app "/Applications/Thunderbird.app"
    add_dock_app "/Applications/WhatsApp.app"
    add_dock_app "/Applications/Spotify.app"
    add_dock_app "/Applications/Visual Studio Code.app"
    add_dock_app "/Applications/Android Studio.app"
    add_dock_app "/System/Applications/System Settings.app"
    add_dock_app "/Applications/AppCleaner.app"
    add_dock_app "/Applications/CapyCard.app"
    add_dock_app "/Applications/UTM.app"

else
    echo "   Warning: dockutil not installed. Skipping Dock icon configuration."
fi

# --- Keyboard ---
echo "   Configuring Keyboard..."
# Fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# --- Screenshots ---
echo "   Configuring Screenshots..."
# Save screenshots to the Pictures/Screenshots folder
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

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

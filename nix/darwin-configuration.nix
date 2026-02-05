{ pkgs, username, darwinHome, lib, config, ... }:

let
  dotfilesDir = "${darwinHome}/dotfiles";
  masApps = {
    "CrystalFetch" = 6454431289;
    "eduVPN" = 1317704208;
    "Image2Icon" = 992115977;
    "Prime Video" = 545519333;
    "Xcode" = 497799835;
  };
in
{
  # Enable Zsh
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # System Packages (Managed by Nix)
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  # Homebrew Configuration
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # Removes packages not listed here
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

    taps = [
      # "homebrew/services" # Deprecated
    ];

    brews = [
      "mas" # Mac App Store CLI
      "duti" # Set default apps
    ];

    casks = [
      # Browsers
      "brave-browser"
      "helium-browser"

      # Development
      "visual-studio-code"
      "android-studio"
      "ghostty"
      "dotnet-sdk"
      "sf-symbols"
      # "pyenv" # Moved to Nix packages or brews

      # Communication
      "thunderbird"
      "whatsapp"
      "zoom"

      # Tools
      "notion"
      "spotify"
      "bitwarden"
      "google-drive"
      "maccy"
      "appcleaner"
      "localsend"
      "raycast"
      "the-unarchiver"

      # Fonts
      "font-meslo-lg-nerd-font"
      "font-fira-code"
      "font-jetbrains-mono"
      "font-hack-nerd-font"
      "font-sf-pro"
      "font-symbols-only-nerd-font"
    ];
    
  };

  # System Defaults
  system.defaults = {
    # Finder
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXSortFoldersFirst = false;
      FXPreferredViewStyle = "Nlsv"; # List view
      AppleShowAllFiles = true; # Hidden files
    };

    # Dock
    dock = {
      orientation = "right";
      tilesize = 39;
      largesize = 60;
      magnification = true;
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0; # Instant animation
      minimize-to-application = true;
      show-recents = false;
      static-only = false;
      
      # Hot Corners
      wvous-tl-corner = 13; # Lock Screen (Example based on your value 13)
      wvous-tr-corner = 4;  # Desktop
      wvous-bl-corner = 5;  # Start Screensaver
      wvous-br-corner = 14; # Quick Note
    };

    # Trackpad
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    # Keyboard
    NSGlobalDomain = {
      KeyRepeat = 1; # Fastest
      InitialKeyRepeat = 10; # Shortest delay
      ApplePressAndHoldEnabled = false;
      
      # Text Editing
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;

      # Appearance
      AppleInterfaceStyle = "Dark";
      
      # Trackpad / Mouse
      "com.apple.swipescrolldirection" = true;
    };
    
    # Menu Bar
    menuExtraClock.Show24Hour = true;
    menuExtraClock.ShowDate = 1; # Always show date
    
    # Screenshots
      screencapture = {
        location = "${darwinHome}/Pictures/Screenshots";
        type = "png";
      };
  };

  # Post-Activation Script: Configure Dock, Wallpaper & Theme
  system.activationScripts.postUserActivation.text = ''
    echo "Setting Default Browser to Helium..."
    if command -v /opt/homebrew/bin/duti >/dev/null; then
      # Resolve Helium bundle id dynamically (falls back if not found)
      HELIUM_BUNDLE_ID="$(osascript -e 'id of app "Helium"' 2>/dev/null || true)"
      if [ -z "$HELIUM_BUNDLE_ID" ]; then
        HELIUM_BUNDLE_ID="com.helium.Helium"
      fi

      # Set Helium as default for http, https, and .html/.pdf (as user)
      sudo -H -u ${username} /opt/homebrew/bin/duti -s "$HELIUM_BUNDLE_ID" http || true
      sudo -H -u ${username} /opt/homebrew/bin/duti -s "$HELIUM_BUNDLE_ID" https || true
      sudo -H -u ${username} /opt/homebrew/bin/duti -s "$HELIUM_BUNDLE_ID" .html || true
      sudo -H -u ${username} /opt/homebrew/bin/duti -s "$HELIUM_BUNDLE_ID" .pdf || true
      
      # Set VS Code as default for .svg
      sudo -H -u ${username} /opt/homebrew/bin/duti -s com.microsoft.VSCode .svg || true
    else
      echo "duti not found, skipping default browser configuration."
    fi

    echo "Configuring Desktop & Dock..."
    
    # Force Dark Mode
    osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' > /dev/null 2>&1

    # Set Wallpaper
    WALLPAPER_PATH="${dotfilesDir}/macos/wallpaper.jpg"
    if [ -f "$WALLPAPER_PATH" ]; then
      echo "Setting wallpaper..."
      osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$WALLPAPER_PATH\"" > /dev/null 2>&1
    fi

    # Configure Dock Icons
    if command -v ${pkgs.dockutil}/bin/dockutil >/dev/null; then
      dockutil=${pkgs.dockutil}/bin/dockutil
      
      # Apps to add to the dock
      apps=(
        "/Applications/Helium.app"
        "/Applications/Brave Browser.app"
        "/Applications/Ghostty.app"
        "/Applications/Notion.app"
        "/Applications/Thunderbird.app"
        "/Applications/WhatsApp.app"
        "/Applications/Spotify.app"
        "/Applications/Visual Studio Code.app"
        "/Applications/Android Studio.app"
        "/System/Applications/System Settings.app"
        "/Applications/AppCleaner.app"
        "/Applications/Bitwarden.app"
      )

      # Clear existing dock
      $dockutil --no-restart --remove all

      # Add apps
      for app in "''${apps[@]}"; do
        if [ -e "$app" ]; then
          $dockutil --no-restart --add "$app"
        else
          echo "App not found: $app"
        fi
      done

      # Restart Dock to apply changes
      killall Dock
    else
      echo "dockutil not found, skipping Dock configuration."
    fi
    
    echo "Configuring Menu Bar..."
    # Enable Bluetooth in Menu Bar
    defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
    # Enable Sound in Menu Bar
    defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true
    # Enable Battery in Menu Bar
    defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
    
    # Hide Spotlight Icon
    defaults write com.apple.Spotlight MenuItemHidden -int 1
    
    # Import Custom Hotkeys (Spotlight disabled, Screenshots, etc.)
    HOTKEYS_PLIST="${dotfilesDir}/macos/hotkeys.plist"
    if [ -f "$HOTKEYS_PLIST" ]; then
      echo "Importing Keyboard Shortcuts..."
      defaults import com.apple.symbolichotkeys "$HOTKEYS_PLIST"
    fi

    echo "Configuring Terminal.app..."
    # Import Coolnight theme securely via plutil
    TERMINAL_PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"
    TERMINAL_THEME_PATH="${dotfilesDir}/macos-terminal/Coolnight.terminal"
    
    if [ -f "$TERMINAL_THEME_PATH" ]; then
      echo "Importing Coolnight terminal theme..."
      
      # Convert XML to binary for safety and insert into Window Settings
      # We rely on the fact that the .terminal file IS a plist dict.
      # We extract the dictionary content and inject it.
      
      # Ensure Window Settings dict exists
      /usr/libexec/PlistBuddy -c "Add :'Window Settings' dict" "$TERMINAL_PLIST" 2>/dev/null || true

      # Delete existing Coolnight profile if present to ensure update
      /usr/libexec/PlistBuddy -c "Delete :'Window Settings':Coolnight" "$TERMINAL_PLIST" 2>/dev/null || true

      # Import the new profile
      # The .terminal file is a full plist with a root dict. We want that root dict content under "Coolnight"
      # But PlistBuddy cannot easily merge external files into a key.
      # So we use 'open' as a fallback if direct injection is too complex in bash, BUT:
      # We can use defaults write with -dict-add if we process the file.
      # Actually, the most robust way for .terminal files IS 'open' because they are specific file types handled by the app.
      # Direct plist injection is risky because .terminal files have a specific structure.
      
      # LET'S STICK TO 'open' BUT MAKE IT BETTER:
      open "$TERMINAL_THEME_PATH"
      sleep 2
      
      # Set as default
      defaults write com.apple.Terminal "Default Window Settings" -string "Coolnight"
      defaults write com.apple.Terminal "Startup Window Settings" -string "Coolnight"
    fi

    # Restart SystemUIServer to apply
    killall SystemUIServer || true
  '';

  # Optional Mac App Store installs (skip if not signed in)
  system.activationScripts.masApps.text = ''
    MAS_BIN="${config.homebrew.brewPrefix}/mas"
    if [ -x "$MAS_BIN" ]; then
      if sudo -H -u ${username} "$MAS_BIN" account >/dev/null 2>&1; then
        echo "Installing Mac App Store apps (optional)..."
${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: id: "        sudo -H -u ${username} \"$MAS_BIN\" install ${toString id} || true") masApps)}
      else
        echo "mas not logged in, skipping App Store installs."
      fi
    else
      echo "mas not found, skipping App Store installs."
    fi
  '';

  # Run Homebrew Bundle as the real user (not root)
  system.activationScripts.homebrew.text = lib.mkForce ''
    echo >&2 "Homebrew bundle (user)..."
    if [ -f "${config.homebrew.brewPrefix}/brew" ]; then
      sudo -H -u ${username} /bin/sh -lc "PATH=${config.homebrew.brewPrefix}:${lib.makeBinPath [ pkgs.mas ]}:$PATH ${config.homebrew.onActivation.brewBundleCmd}"
    else
      echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
    fi
  '';

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Nix configuration
  nix.enable = false; # Let nix-install manage the daemon if unsure, or set to true if multi-user
  # nix.package = pkgs.nix;

  # Backwards compatibility
  system.stateVersion = 6;

  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";

  # User Configuration
  users.users.${username} = {
    name = username;
    home = darwinHome;
  };

  # Allow unfree packages (VS Code, etc.)
  nixpkgs.config.allowUnfree = true;

  # Security / PAM
  security.pam.services.sudo_local.touchIdAuth = true;
}

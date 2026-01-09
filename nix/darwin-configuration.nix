{ pkgs, ... }: {
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
    ];

    casks = [
      # Browsers
      "brave-browser"

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
    
    # Mac App Store Apps (using mas)
    masApps = {
      # "Xcode" = 497799835; # Example
      # Find IDs with `mas search <app>`
    };
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
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      
      # Text Editing
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;

      # Appearance
      AppleInterfaceStyle = "Dark";
      
      # Trackpad / Mouse
      "com.apple.swipescrolldirection" = true;
    };
    
    # Screenshots
    screencapture = {
      location = "/Users/simon/Pictures/Screenshots";
      type = "png";
    };
  };

  # Post-Activation Script: Configure Dock, Wallpaper & Theme
  system.activationScripts.postUserActivation.text = ''
    echo "Configuring Desktop & Dock..."
    
    # Force Dark Mode
    osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' > /dev/null 2>&1

    # Set Wallpaper
    WALLPAPER_PATH="/Users/simon/dotfiles/macos/wallpaper.jpg"
    if [ -f "$WALLPAPER_PATH" ]; then
      echo "Setting wallpaper..."
      osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$WALLPAPER_PATH\"" > /dev/null 2>&1
    fi

    # Configure Dock Icons
    if command -v ${pkgs.dockutil}/bin/dockutil >/dev/null; then
      dockutil=${pkgs.dockutil}/bin/dockutil
      
      # Apps to add to the dock
      apps=(
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
  users.users.simon = {
    name = "simon";
    home = "/Users/simon";
  };

  # Allow unfree packages (VS Code, etc.)
  nixpkgs.config.allowUnfree = true;

  # Security / PAM
  security.pam.enableSudoTouchIdAuth = true;
}
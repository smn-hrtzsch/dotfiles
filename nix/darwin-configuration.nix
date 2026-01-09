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
      "homebrew/services"
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
      "pyenv" # Sometimes better as brew for strict version management, or use nix pkgs.pyenv

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
    };

    # Dock
    dock = {
      tilesize = 39;
      autohide = true;
      autohide-delay = 0.0;
      minimize-to-application = true;
      show-recents = false;
      # Dock icons are harder to manage declaratively with pure defaults, 
      # usually requires a script or `dockutil` run once.
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
    };
    
    # Screenshots
    screencapture = {
      location = "/Users/simon/Pictures/Screenshots";
      type = "png";
    };
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Nix configuration
  nix.enable = false; # Let nix-install manage the daemon if unsure, or set to true if multi-user
  # nix.package = pkgs.nix;

  # Backwards compatibility
  system.stateVersion = 6;

  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Allow unfree packages (VS Code, etc.)
  nixpkgs.config.allowUnfree = true;
}
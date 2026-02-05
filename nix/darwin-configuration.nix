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
    onActivation.cleanup = "none"; # Do not remove packages not listed here
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
      TrackpadThreeFingerDrag = false;
    };

    # Keyboard
    NSGlobalDomain = {
      KeyRepeat = 2; # Standard-ish
      InitialKeyRepeat = 15; # Standard delay
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
  system.activationScripts.postActivation.text = ''
    sudo -H -u ${username} /bin/sh -lc "$(cat <<'EOF'
    echo "Setting Default Browser to Helium..."
    if command -v /opt/homebrew/bin/duti >/dev/null; then
      # Resolve Helium bundle id from app bundle (avoid resolving to Brave)
      HELIUM_APP=""
      if [ -d "/Applications/Helium.app" ]; then
        HELIUM_APP="/Applications/Helium.app"
      elif [ -d "/Applications/Helium Browser.app" ]; then
        HELIUM_APP="/Applications/Helium Browser.app"
      else
        HELIUM_APP="$(mdfind 'kMDItemFSName == "Helium.app" || kMDItemFSName == "Helium Browser.app"' | head -n 1)"
      fi

      HELIUM_BUNDLE_ID=""
      if [ -n "$HELIUM_APP" ]; then
        HELIUM_BUNDLE_ID="$(/usr/bin/mdls -name kMDItemCFBundleIdentifier -raw "$HELIUM_APP" 2>/dev/null)"
      fi
      if [ -z "$HELIUM_BUNDLE_ID" ]; then
        HELIUM_BUNDLE_ID="net.imput.helium"
      fi

      supports_scheme() {
        local app="$1"
        local scheme="$2"
        /usr/bin/python3 - <<'PY' "$app" "$scheme" >/dev/null 2>&1
import plistlib, sys
path = sys.argv[1]
scheme = sys.argv[2]
try:
    with open(path, 'rb') as f:
        data = plistlib.load(f)
    for entry in data.get('CFBundleURLTypes', []):
        for s in entry.get('CFBundleURLSchemes', []):
            if s == scheme:
                sys.exit(0)
except Exception:
    pass
sys.exit(1)
PY
      }

      get_handler() {
        local ext="$1"
        /opt/homebrew/bin/duti -x "$ext" 2>/dev/null | awk '{print $1}'
      }

      set_ext_if_needed() {
        local ext="$1"
        local desired="$2"
        local current
        current=$(get_handler "$ext")
        if [ "$current" != "$desired" ]; then
          sudo -H -u ${username} /opt/homebrew/bin/duti -s "$desired" ".$ext" >/dev/null 2>&1 || true
        fi
      }

      set_scheme_if_supported() {
        local scheme="$1"
        local desired="$2"
        if [ -n "$HELIUM_APP" ] && supports_scheme "$HELIUM_APP/Contents/Info.plist" "$scheme"; then
          sudo -H -u ${username} /opt/homebrew/bin/duti -s "$desired" "$scheme" >/dev/null 2>&1 || true
        fi
      }

      # Set Helium as default for http only if app declares the scheme
      set_scheme_if_supported "http" "$HELIUM_BUNDLE_ID"

      # File types (only set if needed)
      set_ext_if_needed "html" "$HELIUM_BUNDLE_ID"
      set_ext_if_needed "pdf" "$HELIUM_BUNDLE_ID"

      # Set VS Code as default for .svg (only if needed)
      set_ext_if_needed "svg" "com.microsoft.VSCode"
    else
      echo "duti not found, skipping default browser configuration."
    fi

    echo "Configuring Desktop & Dock..."
    
    # Force Dark Mode (only if needed)
    if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" != "Dark" ]; then
      osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' > /dev/null 2>&1
    fi

    # Set Wallpaper
    WALLPAPER_PATH="${dotfilesDir}/macos/wallpaper.jpg"
    if [ -f "$WALLPAPER_PATH" ]; then
      current_wallpaper=$(osascript -e 'tell application "System Events" to get picture of first desktop' 2>/dev/null || true)
      if [ "$current_wallpaper" != "$WALLPAPER_PATH" ]; then
        echo "Setting wallpaper..."
        osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$WALLPAPER_PATH\"" > /dev/null 2>&1
      fi
    fi

    # Configure Dock Icons
    if command -v ${pkgs.dockutil}/bin/dockutil >/dev/null; then
      dockutil=${pkgs.dockutil}/bin/dockutil
      dock_target="${darwinHome}"
      
      # Apps to add to the dock
      helium_app=""
      if [ -d "/Applications/Helium Browser.app" ]; then
        helium_app="/Applications/Helium Browser.app"
      elif [ -d "/Applications/Helium.app" ]; then
        helium_app="/Applications/Helium.app"
      fi

      apps=(
        "$helium_app"
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

      # Only update Dock if it differs
      current_apps=$("$dockutil" --list "$dock_target" 2>/dev/null | awk -F '\t' '$2 ~ /\.app$/ {print $2}')
      desired_apps=()
      for app in "''${apps[@]}"; do
        if [ -n "$app" ] && [ -e "$app" ]; then
          desired_apps+=("$app")
        fi
      done
      if [ "$(printf '%s\n' "''${desired_apps[@]}")" != "$current_apps" ]; then
        # Clear existing dock
        $dockutil --no-restart --remove all "$dock_target"

        # Add apps
        for app in "''${apps[@]}"; do
          if [ -e "$app" ]; then
            $dockutil --no-restart --add "$app" "$dock_target"
          else
            echo "App not found: $app"
          fi
        done

        # Restart Dock to apply changes
        killall Dock
      else
        echo "Dock already configured."
      fi
    else
      echo "dockutil not found, skipping Dock configuration."
    fi
    
    echo "Configuring Menu Bar..."
    # Enable Bluetooth/Sound/Battery in Menu Bar (only if needed)
    if [ "$(defaults read com.apple.controlcenter "NSStatusItem Visible Bluetooth" 2>/dev/null)" != "1" ]; then
      defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
    fi
    if [ "$(defaults read com.apple.controlcenter "NSStatusItem Visible Sound" 2>/dev/null)" != "1" ]; then
      defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true
    fi
    if [ "$(defaults read com.apple.controlcenter "NSStatusItem Visible Battery" 2>/dev/null)" != "1" ]; then
      defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
    fi
    
    # Hide Spotlight Icon (only if needed)
    if [ "$(defaults read com.apple.Spotlight MenuItemHidden 2>/dev/null)" != "1" ]; then
      defaults write com.apple.Spotlight MenuItemHidden -int 1
    fi
    
    # Import Custom Hotkeys (Spotlight disabled, Screenshots, etc.)
    HOTKEYS_PLIST="${dotfilesDir}/macos/hotkeys.plist"
    if [ -f "$HOTKEYS_PLIST" ]; then
      HOTKEYS_HASH_FILE="$HOME/Library/Preferences/.dotfiles_hotkeys.sha256"
      new_hash=$(shasum -a 256 "$HOTKEYS_PLIST" | awk '{print $1}')
      old_hash=$(cat "$HOTKEYS_HASH_FILE" 2>/dev/null || true)
      if [ "$new_hash" != "$old_hash" ]; then
        echo "Importing Keyboard Shortcuts..."
        defaults import com.apple.symbolichotkeys "$HOTKEYS_PLIST"
        echo "$new_hash" > "$HOTKEYS_HASH_FILE"
      else
        echo "Keyboard Shortcuts already up to date."
      fi
    fi

    echo "Configuring Terminal.app..."
    # Import Coolnight theme securely via plutil
    TERMINAL_THEME_PATH="${dotfilesDir}/macos-terminal/Coolnight.terminal"
    
    if [ -f "$TERMINAL_THEME_PATH" ]; then
      current_default=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null || true)
      current_startup=$(defaults read com.apple.Terminal "Startup Window Settings" 2>/dev/null || true)
      if [ "$current_default" != "Coolnight" ] || [ "$current_startup" != "Coolnight" ]; then
        echo "Importing Coolnight terminal theme..."
        open "$TERMINAL_THEME_PATH"
        sleep 2
        
        # Set as default
        defaults write com.apple.Terminal "Default Window Settings" -string "Coolnight"
        defaults write com.apple.Terminal "Startup Window Settings" -string "Coolnight"
      else
        echo "Terminal theme already set to Coolnight."
      fi
    fi

    # Restart SystemUIServer to apply
    killall SystemUIServer || true
EOF
    )"
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

  # Primary user for user-scoped defaults
  system.primaryUser = username;

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

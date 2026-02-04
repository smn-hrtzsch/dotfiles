# nix/home.nix
{ pkgs, config, username, homeDirectory, gitUserName, gitUserEmail, isWSL, ... }:

let
  dotfilesDir = "${homeDirectory}/dotfiles";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "24.11";

  # Fontconfig (for Nerd Fonts)
  fonts.fontconfig.enable = true;

  # XDG (Desktop Entries)
  xdg.enable = true;

  # User Packages
  home.packages = with pkgs; [
    # Shell & Tools
    stow
    unzip
    curl
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    eza
    zoxide
    neofetch
    fzf
    bat
    gh
    jq
    git-lfs
    cmake
    cloc
    shellcheck
    direnv
    tree
    pyenv
    
    # GUI Tools (available via Nix, works on Linux/WSL if GUI support is active)
    wezterm
    
    # Node.js & Tools
    nodejs_22
    
    # Rust
    cargo
    rustc
    
    # Java
    openjdk21

    # .NET
    dotnet-sdk_9

    # Android
    android-tools

    # Fun/Misc
    # ...
  ] ++ (if pkgs.stdenv.isDarwin then [
    pkgs.dockutil # Install dockutil only on macOS
  ] else if isWSL then [
    pkgs.wslu # WSL Utilities only on WSL
  ] else (
    let
      linuxGuiApps = if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then [
        # Generic Linux GUI Apps (x86_64)
        pkgs.brave
        pkgs.vscode
        pkgs.spotify
        pkgs.thunderbird
        pkgs.bitwarden
        # pkgs.notion-app-enhanced
        pkgs.whatsapp-for-linux
        pkgs.zoom-us
        pkgs.localsend
        pkgs.ghostty # Terminal
        pkgs.copyq   # Clipboard manager (Maccy alternative)
        pkgs.rclone  # Cloud storage (Google Drive etc.)
        pkgs.p7zip   # Archive tool (The Unarchiver alternative)
        pkgs.android-studio # IDE
      ] else [
        # Generic Linux GUI Apps (aarch64)
        # Note: Brave/VS Code are installed via vendor repos in bootstrap on ARM64.
        pkgs.firefox
        pkgs.vscodium
        pkgs.thunderbird
        pkgs.localsend
        pkgs.ghostty
        pkgs.copyq
        pkgs.rclone
        pkgs.p7zip
      ];
    in
      linuxGuiApps ++ [
        # Fonts
        pkgs.nerd-fonts.meslo-lg
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.jetbrains-mono
      ] ++ (if (pkgs.stdenv.isLinux && !isWSL) then [
        # Desktop integration (Linux only)
        pkgs.xdg-utils
      ] else [])
  ));

  # Allow unfree packages (VS Code, Spotify, etc.)
  nixpkgs.config.allowUnfree = true;

  # --- Linux Desktop Configuration (GNOME) ---
  # Applies only on Linux (not WSL, not macOS)
  dconf = if (pkgs.stdenv.isLinux && !isWSL) then {
    enable = true;
    settings = {
      # Dark Mode & Theme
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };

      # Wallpaper
      "org/gnome/desktop/background" = {
        picture-uri = "file://${homeDirectory}/.local/share/backgrounds/wallpaper.jpg";
        picture-uri-dark = "file://${homeDirectory}/.local/share/backgrounds/wallpaper.jpg";
      };

      # Dock (Taskbar) Configuration
      "org/gnome/shell" = {
        favorite-apps = [
          "org.gnome.Nautilus.desktop"       # Finder equivalent
          "brave-browser.desktop"
          "com.mitchellh.ghostty.desktop"
          # "notion.desktop"                 # Skipped (not in nixpkgs)
          "thunderbird.desktop"
          "whatsapp-for-linux.desktop"
          "spotify.desktop"
          "code.desktop"
          "android-studio.desktop"
          "org.gnome.Settings.desktop"
          "bitwarden.desktop"
        ];
      };
      
      # Window Buttons (macOS Style: Left side)
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "close,minimize,maximize:"; # Colons separate left:right
      };

      # GNOME Terminal (Coolnight theme + Meslo Nerd Font)
      "org/gnome/terminal/legacy" = {
        default-show-menubar = false;
      };

      "org/gnome/terminal/legacy/profiles:" = {
        default = "b1dcc9dd-5262-4d8d-a863-c897e6d979b9";
        list = [ "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" ];
      };

      "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        visible-name = "Coolnight";
        use-theme-colors = false;
        use-system-font = false;
        font = "MesloLGS Nerd Font Mono 16";
        foreground-color = "#CBE0F0";
        background-color = "#181818";
        cursor-background-color = "#47FF9C";
        cursor-foreground-color = "#011423";
        cursor-colors-set = true;
        bold-is-bright = true;
        palette = [
          "#6f8a9e" "#E52E2E" "#44FFB1" "#FFE073"
          "#0FC5ED" "#a277ff" "#24EAF7" "#24EAF7"
          "#6f8a9e" "#E52E2E" "#44FFB1" "#FFE073"
          "#A277FF" "#a277ff" "#24EAF7" "#24EAF7"
        ];
      };
      
      # Keyboard Tweaks (optional)
      # "org/gnome/desktop/wm/keybindings" = {
      #   close = ["<Super>w"];
      # };
    };
  } else {};

  # Programs Configuration
  programs.home-manager.enable = true;
  
  programs.java = {
    enable = true;
    package = pkgs.openjdk21;
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()
      
      -- Start in WSL by default
      ${if isWSL then "config.default_domain = 'WSL:WSL-Nix'" else ""}

      -- Font
      config.font = wezterm.font 'MesloLGS NF'
      config.font_size = 12.0 -- 16.0 might be too large on Windows/Linux by default

      -- Window
      config.window_padding = {
        left = 10,
        right = 10,
        top = 10,
        bottom = 10,
      }
      config.window_background_opacity = 1.0
      config.hide_tab_bar_if_only_one_tab = true
      
      -- Cursor
      config.default_cursor_style = 'BlinkingBar'
      
      -- Colors (Coolnight Theme)
      config.colors = {
        foreground = '#CBE0F0',
        background = '#181818',
        cursor_bg = '#47FF9C',
        cursor_fg = '#011423',
        cursor_border = '#47FF9C',
        selection_fg = '#CBE0F0',
        selection_bg = '#585b70',
        
        ansi = {
          '#6f8a9e', -- Black
          '#E52E2E', -- Red
          '#44FFB1', -- Green
          '#FFE073', -- Yellow
          '#0FC5ED', -- Blue
          '#a277ff', -- Magenta
          '#24EAF7', -- Cyan
          '#24EAF7', -- White (duplicate in source)
        },
        brights = {
          '#6f8a9e', -- Black
          '#E52E2E', -- Red
          '#44FFB1', -- Green
          '#FFE073', -- Yellow
          '#A277FF', -- Blue (mapped from palette 12)
          '#a277ff', -- Magenta
          '#24EAF7', -- Cyan
          '#24EAF7', -- White
        },
      }

      -- Keybindings (Mapped from Ghostty)
      -- Ghostty: Super+Shift+Arrow (Nav) -> WezTerm: Alt+Shift+Arrow
      -- Ghostty: Super+Alt+Arrow (Resize) -> WezTerm: Alt+Ctrl+Arrow
      config.keys = {
        -- Split Navigation
        { key = 'UpArrow', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
        { key = 'DownArrow', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
        { key = 'LeftArrow', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
        { key = 'RightArrow', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
        
        -- Split Resize
        { key = 'UpArrow', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
        { key = 'DownArrow', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
        { key = 'LeftArrow', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
        { key = 'RightArrow', mods = 'ALT|CTRL', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
        
        -- Create Split
        { key = 'd', mods = 'ALT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = 'd', mods = 'ALT|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
        
        -- Tabs & Panes
        { key = 't', mods = 'ALT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
        { key = 'w', mods = 'ALT', action = wezterm.action.CloseCurrentPane { confirm = false } },
        
        -- Clipboard
        { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
        { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
        { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
      }

      -- Tab Switching (Alt + 1..9)
      for i = 1, 9 do
        table.insert(config.keys, {
          key = tostring(i),
          mods = 'ALT',
          action = wezterm.action.ActivateTab(i - 1),
        })
      end
      
      return config
    '';
  };
  
  # Install global NPM packages from file
  home.activation.installNpmGlobals = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -f "${dotfilesDir}/npm/npm-globals.txt" ]; then
      echo "Installing global NPM packages..."
      
      # Use explicit npm path from the installed package
      npm="${pkgs.nodejs_22}/bin/npm"
      node_path="${pkgs.nodejs_22}/bin"
      
      # Add node to PATH for build scripts
      export PATH="$node_path:$PATH"
      
      # Configure npm prefix if not set to avoid permission issues
      if [[ "$($npm config get prefix)" == "/nix/store"* ]]; then
        $npm config set prefix "$HOME/.npm-global"
        export PATH="$HOME/.npm-global/bin:$PATH"
      fi
      
      while IFS= read -r package || [[ -n "$package" ]]; do
        if [[ -n "$package" && ! "$package" =~ ^# ]]; then
          if ! $npm list -g "$package" >/dev/null 2>&1; then
             echo "Installing $package..."
             $npm install -g "$package"
          fi
        fi
      done < "${dotfilesDir}/npm/npm-globals.txt"
    fi
  '';

  home.activation.refreshFontCache = config.lib.dag.entryAfter ["writeBoundary"] ''
    if command -v fc-cache >/dev/null 2>&1; then
      fc-cache -f
    fi
  '';

  home.activation.applyGnomeTerminalTheme = config.lib.dag.entryAfter ["writeBoundary"] ''
    if command -v gsettings >/dev/null 2>&1 && [[ -n "$DBUS_SESSION_BUS_ADDRESS" ]]; then
      profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
      if [[ -n "$profile_id" ]]; then
        profile_path="/org/gnome/terminal/legacy/profiles:/:$profile_id/"
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path use-theme-colors false
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path use-system-font false
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path font "MesloLGS Nerd Font Mono 16"
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path foreground-color "#CBE0F0"
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path background-color "#181818"
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path cursor-background-color "#47FF9C"
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path cursor-foreground-color "#011423"
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path cursor-colors-set true
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path bold-is-bright true
        gsettings set org.gnome.Terminal.Legacy.Profile:$profile_path palette "['#6f8a9e', '#E52E2E', '#44FFB1', '#FFE073', '#0FC5ED', '#a277ff', '#24EAF7', '#24EAF7', '#6f8a9e', '#E52E2E', '#44FFB1', '#FFE073', '#A277FF', '#a277ff', '#24EAF7', '#24EAF7']"
      fi
    fi
  '';

  home.activation.stowCodex = config.lib.dag.entryAfter ["writeBoundary"] ''
    if command -v stow >/dev/null 2>&1; then
      if [[ -d "${dotfilesDir}/codex" ]]; then
        stow --restow -d "${dotfilesDir}" -t "${homeDirectory}" codex
      fi
    fi
  '';

  # Automatically run Android SDK setup on Linux
  home.activation.setupAndroid = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [[ "$(uname)" == "Linux" ]]; then
      echo "Checking Android SDK setup..."
      # Use the script from the dotfiles directory
      if [ -f "${dotfilesDir}/scripts/setup_android.sh" ]; then
        bash "${dotfilesDir}/scripts/setup_android.sh"
      fi
    fi
  '';

  programs.git = {
    enable = true;
    userName = gitUserName; 
    userEmail = gitUserEmail;
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.excludesfile = "~/.gitignore_global";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Ensure system paths are present early (fixes mkdir/dirname not found issues in HM generated config)
    envExtra = ''
      export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    '';
    
    initContent = ''
      # Nix: Load Powerlevel10k directly from Nix store
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Source existing zshrc from dotfiles
      if [ -f ${dotfilesDir}/zsh/.zshrc ]; then
        source ${dotfilesDir}/zsh/.zshrc
      fi
    '';
  };
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = false; # We manage this in .zshrc
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = false; # We manage aliases in .zshrc
  };
  
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # We manage this in .zshrc
  };
  
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true; # Keep this, it's complex to setup manually
  };

  # Symlink Dotfiles
  home.file = {
    ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/ghostty";
    # Link p10k config directly to home
    ".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/zsh/.p10k.zsh";
    
    # Gemini CLI Config (individual files/dirs to preserve local state like oauth, history)
    ".gemini/commands".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gemini/.gemini/commands";
    ".gemini/GEMINI.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gemini/.gemini/GEMINI.md";
    ".gemini/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gemini/.gemini/settings.json";
    ".gemini/skills".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/anthropic-skills/skills";
    
    # sketchybar is macOS only
    ".config/raycast".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/raycast";
    ".config/gh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/gh";
    ".config/neofetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/neofetch";
    
    # Manual Dotfiles
    ".ssh/config".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/ssh/config";
    ".npmrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/npm/.npmrc";
    ".config/opencode".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/opencode";
    ".opencode/commands".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/opencode/.opencode/commands";
  } // (if (pkgs.stdenv.isLinux && !isWSL) then {
    ".local/share/backgrounds/wallpaper.jpg".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/macos/wallpaper.jpg";
  } else {}) // (if pkgs.stdenv.isDarwin then {
    ".config/sketchybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/sketchybar";
  } else {});

  # Desktop entries (Linux only)
  xdg.desktopEntries = (if (pkgs.stdenv.isLinux && !isWSL) then {
    ghostty = {
      name = "Ghostty";
      exec = "ghostty";
      icon = "ghostty";
      type = "Application";
      terminal = false;
      categories = [ "System" "TerminalEmulator" ];
    };
    ghostty-x11 = {
      name = "Ghostty (X11)";
      exec = "env GDK_BACKEND=x11 GSK_RENDERER=cairo LIBGL_ALWAYS_SOFTWARE=1 ghostty";
      icon = "ghostty";
      type = "Application";
      terminal = false;
      categories = [ "System" "TerminalEmulator" ];
    };
  } else {});

}

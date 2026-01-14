# nix/home.nix
{ pkgs, config, username, homeDirectory, ... }:

let
  dotfilesDir = "${homeDirectory}/dotfiles";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "24.11";

  # User Packages
  home.packages = with pkgs; [
    # Shell & Tools
    stow
    unzip
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    wslu # WSL Utilities (wslview for 'open' command)
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

    # Android
    android-tools

    # Fun/Misc
    # ...
  ] ++ (if pkgs.stdenv.isDarwin then [
    pkgs.dockutil # Install dockutil only on macOS
  ] else []);

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
      config.default_domain = 'WSL:WSL-Nix'

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
    userName = "Simon Hörtzsch"; 
    userEmail = "simon@hoertzsch.de";
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
    
    # Gemini CLI Config
    ".gemini".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gemini/.gemini";
    
    # sketchybar is macOS only
    ".config/raycast".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/raycast";
    ".config/gh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/gh";
    ".config/neofetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/neofetch";
    
    # Manual Dotfiles
    ".ssh/config".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/ssh/config";
    ".npmrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/npm/.npmrc";
  } // (if pkgs.stdenv.isDarwin then {
    ".config/sketchybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/sketchybar";
  } else {});

}
{ pkgs, config, gitUserName, gitUserEmail, isWSL, lib, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
  anthropicSkillsDir = "${dotfilesDir}/anthropic-skills/skills";
  customCodexSkills = [
    "opencode-commit"
    "opencode-execute"
    "opencode-feature"
    "opencode-fix"
    "opencode-plan"
    "opencode-refactor"
    "opencode-review"
    "opencode-secrets"
  ];
in
{
  home.packages = with pkgs; [
    # Shell & Tools
    unzip
    curl
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    eza
    zoxide
    neofetch
    ripgrep
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
  ];

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

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = gitUserName;
        email = gitUserEmail;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.excludesfile = "~/.gitignore_global";
    };
  };

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
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

  home.activation.fixGhosttyRepoConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
    ghostty_home="$HOME/.config/ghostty"
    ghostty_repo="${dotfilesDir}/config/.config/ghostty"

    resolve_path() {
      if command -v realpath >/dev/null 2>&1; then
        realpath -m "$1" 2>/dev/null || echo "$1"
      elif command -v readlink >/dev/null 2>&1; then
        readlink -f "$1" 2>/dev/null || readlink "$1" 2>/dev/null || echo "$1"
      else
        echo "$1"
      fi
    }

    home_target=$(resolve_path "$ghostty_home")
    repo_target=$(resolve_path "$ghostty_repo")
    skip_links=0
    case "$home_target" in
      "$repo_target"|"$repo_target"/*)
        skip_links=1
        ;;
    esac

    if [ "$skip_links" -eq 0 ] && [ -L "$ghostty_home" ]; then
      link_target=$(resolve_path "$ghostty_home")
      case "$link_target" in
        "$repo_target"|"$repo_target"/*)
          rm -f "$ghostty_home"
          mkdir -p "$ghostty_home"
          ;;
      esac
    fi

    if [ "$skip_links" -eq 0 ]; then
      if [ -e "$ghostty_repo/config" ]; then
        rm -f "$ghostty_repo/config"
      fi

      if [ -d "$ghostty_home" ]; then
        if [ ! -e "$ghostty_home/themes" ]; then
          ln -sfn "$ghostty_repo/themes" "$ghostty_home/themes"
        fi

        if [ ! -e "$ghostty_home/config" ]; then
          if [ "$(uname)" = "Darwin" ]; then
            ln -sfn "$ghostty_repo/config.darwin" "$ghostty_home/config"
          else
            ln -sfn "$ghostty_repo/config.linux" "$ghostty_home/config"
          fi
        fi
      fi
    fi
    if [ "$skip_links" -ne 0 ]; then
      if [ ! -e "$ghostty_repo/config" ]; then
        if [ "$(uname)" = "Darwin" ]; then
          ln -sfn "$ghostty_repo/config.darwin" "$ghostty_repo/config"
        else
          ln -sfn "$ghostty_repo/config.linux" "$ghostty_repo/config"
        fi
      fi
    fi
  '';

  home.activation.linkCodexAnthropicSkills = config.lib.dag.entryAfter ["writeBoundary"] ''
    skills_src="${anthropicSkillsDir}"
    skills_dst="$HOME/.codex/skills"

    if [ -d "$skills_src" ]; then
      mkdir -p "$skills_dst"

      for skill in "$skills_src"/*; do
        if [ -d "$skill" ]; then
          name=$(basename "$skill")
          case "$name" in
            opencode-commit|opencode-execute|opencode-feature|opencode-fix|opencode-plan|opencode-refactor|opencode-review|opencode-secrets)
              continue
              ;;
          esac
          ln -sfn "$skill" "$skills_dst/$name"
        fi
      done
    fi
  '';


  # Symlink Dotfiles
  home.file = {
    # .config/opencode
    ".config/opencode/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/opencode/AGENTS.md";
    ".config/opencode/config.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/opencode/config.json";
    ".config/opencode/commands".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/opencode/.opencode/commands";
    ".config/opencode/skills".source = config.lib.file.mkOutOfStoreSymlink anthropicSkillsDir;

    # Other .config tools
    ".config/gh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/gh";
    ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/ghostty";
    ".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/wezterm";
    # ".config/direnv" is managed by programs.direnv
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/nvim";
    ".config/neofetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/neofetch";
    ".config/sketchybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/sketchybar";
    ".config/mpv".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/mpv";
    ".config/raycast".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/.config/raycast";

    # Home root files
    ".vscode".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/vscode/.vscode";
    ".warp".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/warp/.warp";
    ".condarc".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/conda/.condarc";
    ".zprofile".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/zsh/.zprofile";
    "npm-globals.txt".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/npm/npm-globals.txt";

    ".gitconfig" = {
      text = "";
      force = true;
    };

    # Link p10k config directly to home
    ".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/zsh/.p10k.zsh";

    # Gemini CLI Config (individual files/dirs to preserve local state like oauth, history)
    ".gemini/commands".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gemini/.gemini/commands";
    ".gemini/GEMINI.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gemini/.gemini/GEMINI.md";
    ".gemini/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/gemini/.gemini/settings.json";
    ".gemini/skills".source = config.lib.file.mkOutOfStoreSymlink anthropicSkillsDir;

    # Manual Dotfiles
    ".ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink (
        if pkgs.stdenv.isDarwin
        then "${dotfilesDir}/ssh/config.darwin"
        else "${dotfilesDir}/ssh/config"
      );
      force = true;
    };
    ".npmrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/npm/.npmrc";

    # Codex config and custom skills (managed via Home Manager)
    ".codex/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/config.toml";
    ".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/AGENTS.md";

    ".codex/skills/opencode-commit" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/skills/opencode-commit";
      force = true;
    };
    ".codex/skills/opencode-execute" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/skills/opencode-execute";
      force = true;
    };
    ".codex/skills/opencode-feature" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/skills/opencode-feature";
      force = true;
    };
    ".codex/skills/opencode-fix" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/skills/opencode-fix";
      force = true;
    };
    ".codex/skills/opencode-plan" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/skills/opencode-plan";
      force = true;
    };
    ".codex/skills/opencode-refactor" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/skills/opencode-refactor";
      force = true;
    };
    ".codex/skills/opencode-review" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/skills/opencode-review";
      force = true;
    };
    ".codex/skills/opencode-secrets" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/.codex/skills/opencode-secrets";
      force = true;
    };
  };
}

{ pkgs, config, lib, isWSL, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
  ghosttyExec = if pkgs.stdenv.hostPlatform.system == "aarch64-linux" then "/usr/bin/ghostty" else "ghostty";
  ghosttyExecVm = if pkgs.stdenv.hostPlatform.system == "aarch64-linux"
    then "env GDK_BACKEND=x11 GSK_RENDERER=cairo LIBGL_ALWAYS_SOFTWARE=1 /usr/bin/ghostty"
    else "ghostty";
  linuxGuiApps = with pkgs; if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then [
    # Generic Linux GUI Apps (x86_64)
    brave
    vscode
    spotify
    thunderbird
    bitwarden-desktop
    # notion-app-enhanced
    zoom-us
    localsend
    ghostty
    copyq
    rclone
    p7zip
  ] else [
    # Generic Linux GUI Apps (aarch64)
    # Note: Brave/VS Code/Ghostty are installed via vendor repos in bootstrap on ARM64.
    firefox
    vscodium
    thunderbird
    localsend
    copyq
    rclone
    p7zip
  ];
  linuxExtraPackages = with pkgs; [
    nerd-fonts.meslo-lg
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    xdg-utils
  ];
in
lib.mkIf pkgs.stdenv.isLinux {
  # Fontconfig (for Nerd Fonts)
  fonts.fontconfig.enable = true;

  # XDG (Desktop Entries)
  xdg.enable = true;

  manual.manpages.enable = false;

  home.packages = lib.optionals (!isWSL) (linuxGuiApps ++ linuxExtraPackages);

  # --- Linux Desktop Configuration (GNOME) ---
  dconf = lib.mkIf (!isWSL) {
    enable = true;
    settings = {
      # Dark Mode & Theme
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };

      # Wallpaper
      "org/gnome/desktop/background" = {
        picture-uri = "file://${config.home.homeDirectory}/.local/share/backgrounds/wallpaper.jpg";
        picture-uri-dark = "file://${config.home.homeDirectory}/.local/share/backgrounds/wallpaper.jpg";
      };

      # Dock (Taskbar) Configuration
      "org/gnome/shell" = {
        favorite-apps = [
          "org.gnome.Nautilus.desktop"       # Finder equivalent
          "brave-browser.desktop"
          "ghostty.desktop"                  # Ghostty (VM-safe)
          "org.gnome.Terminal.desktop"       # GNOME Terminal
          # "notion.desktop"                 # Skipped (not in nixpkgs)
          "thunderbird.desktop"
          "spotify.desktop"
          "code.desktop"
          "org.gnome.Settings.desktop"
          "bitwarden.desktop"
        ];
      };

      # Window Buttons (Linux standard: right side)
      "org/gnome/desktop/wm/preferences" = {
        button-layout = ":minimize,maximize,close"; # Colons separate left:right
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
    };
  };

  home.file = lib.mkIf (!isWSL) {
    ".local/share/backgrounds/wallpaper.jpg".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/macos/wallpaper.jpg";
  };

  home.activation = lib.mkMerge [
    {
      refreshFontCache = config.lib.dag.entryAfter ["writeBoundary"] ''
        if command -v fc-cache >/dev/null 2>&1; then
          fc-cache -f
        fi
      '';

      setupAndroid = config.lib.dag.entryAfter ["writeBoundary"] ''
        if [[ "$(uname)" == "Linux" ]]; then
          echo "Checking Android SDK setup..."
          if [ -f "${dotfilesDir}/scripts/setup_android.sh" ]; then
            bash "${dotfilesDir}/scripts/setup_android.sh"
          fi
        fi
      '';
    }
    (lib.mkIf (!isWSL) {
      applyGnomeTerminalTheme = config.lib.dag.entryAfter ["dconfSettings"] ''
        if command -v gsettings >/dev/null 2>&1 \
          && gsettings list-schemas | grep -q "org.gnome.Terminal.ProfilesList"; then

          apply_theme() {
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
          }

          if [[ -n "$DBUS_SESSION_BUS_ADDRESS" ]]; then
            apply_theme
          else
            if command -v dbus-run-session >/dev/null 2>&1; then
              dbus-run-session -- bash -c "$(declare -f apply_theme); apply_theme"
            fi
          fi
        fi
      '';

      updateDesktopDatabase = config.lib.dag.entryAfter ["writeBoundary"] ''
        if command -v update-desktop-database >/dev/null 2>&1; then
          update-desktop-database "$HOME/.local/share/applications" || true
        fi
      '';
    })
  ];

  # Desktop entries (Linux only)
  xdg.desktopEntries = lib.mkIf (!isWSL) {
    ghostty = {
      name = "Ghostty";
      exec = ghosttyExecVm;
      icon = "ghostty";
      type = "Application";
      terminal = false;
      categories = [ "System" "TerminalEmulator" ];
    };
    ghostty-native = {
      name = "Ghostty (Native)";
      exec = ghosttyExec;
      icon = "ghostty";
      type = "Application";
      terminal = false;
      categories = [ "System" "TerminalEmulator" ];
    };
  };
}

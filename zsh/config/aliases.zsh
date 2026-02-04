# ---- Aliases ----

# Standard Tools Ersatz
alias ls="eza --icons=always -laa --links --group"
alias cd="z"

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../../..'
alias .....='cd ../../../../..'
alias c='clear'

# Git Shortcuts
alias g='git'
alias gits='git status'
alias ga='git add'
alias ga.='git add .'
alias gc='git commit -m'
alias gcam='git commit -a -m'
alias gp='git push'

# Python
alias python='python3'
alias pip='python3 -m pip'

# System Maintenance
alias rebuild='rebuild-auto'
alias rebuild-macos='rebuild-macos'
alias rebuild-linux='rebuild-linux'
alias rebuild-wsl='rebuild-wsl'

# Web Helpers
alias google='function _google() { local query=$(echo "$*" | sed "s/ /+/g"); open "https://www.google.com/search?q=$query"; }; _google'
alias openweb='function _openweb() { local url="https://$1"; open "$url"; }; _openweb'

# Project Shortcuts
if [[ -f "$HOME/Documents/TUBAF/WiSe-25_26/KI/.bouncai-env/bin/activate" ]]; then
    alias bouncai-env="source \"$HOME/Documents/TUBAF/WiSe-25_26/KI/.bouncai-env/bin/activate\""
elif [[ -f "/mnt/c/Users/Simon/Documents/TUBAF/KI-WS-25-26/bouncai-env/bin/activate" ]]; then
    alias bouncai-env="source \"/mnt/c/Users/Simon/Documents/TUBAF/KI-WS-25-26/bouncai-env/bin/activate\""
else
    alias bouncai-env="echo 'Keine BouncAI Umgebung gefunden.'"
fi

# ROS2 Aliases
alias startros2='
  echo "INFO: Wechsle in den ROS2 Workspace (~/ros2_ws)..."
  cd ~/ros2_ws/src/waymo && \
  echo "INFO: Aktiviere Conda-Umgebung ros2..."
  conda activate ros2 && \
  echo "INFO: Conda-Umgebung ros2 aktiviert." && \
  echo "INFO: Source ROS2 Workspace Setup-Datei (~/ros2_ws/install/setup.zsh)..."
  source ~/ros2_ws/install/setup.zsh && \
  source ~/ros2_ws/install/local_setup.zsh && \
  echo " -------------------------------------------------------"
  echo "| ROS2 Waymo Umgebung erfolgreich eingerichtet!         |"
  echo "| Aktuelles Verzeichnis: $(pwd) |"
  echo "| Aktive Conda-Umgebung: $CONDA_DEFAULT_ENV                           |"
  echo "| ROS Distro (falls gesetzt): $ROS_DISTRO                    |"
  echo " -------------------------------------------------------"
'

alias stopros2=' 
  echo "INFO: Deaktiviere Conda-Umgebung ros2..."
  conda deactivate && \
  echo "INFO: Wechsle zurück in das Home-Verzeichnis..."
  cd ~ && \
  echo " -------------------------------------------------------"
  echo "| ROS2 Waymo Umgebung erfolgreich deaktiviert!          |"
  echo "| Aktuelles Verzeichnis: $(pwd)                   |"
  echo " -------------------------------------------------------"
'

# Emulator
alias startemulator=' 
  echo "1. Starte ADB-Server..."
  adb start-server

  # Geben Sie dem ADB-Server eine Sekunde Zeit zum Initialisieren
  sleep 1

  echo "2. Starte Pixel_9_Pro_XL Emulator (mit Quick Boot Snapshot)..."
  emulator -avd Pixel_9_Pro_XL &

  echo "3. Prüfe ADB-Gerätestatus..."
  # Dieser Befehl wartet, bis das Gerät ONLINE ist (Timeout nach 60s)
  adb wait-for-device

  echo "Emulator ist verbunden und bereit."
'

alias run_capy_card_on_ios=' 
  cd $HOME/CapyCode/CapyCard && \
  dotnet build CapyCard/CapyCard.iOS/CapyCard.iOS.csproj -f net9.0-ios && \
  (xcrun simctl boot 93967CA2-E319-4C19-8212-E675A99A65BA 2>/dev/null || true) && \
  open -a Simulator && \
  xcrun simctl install 93967CA2-E319-4C19-8212-E675A99A65BA CapyCard/CapyCard.iOS/bin/Debug/net9.0-ios/iossimulator-arm64/CapyCard.iOS.app && \
  xcrun simctl launch 93967CA2-E319-4C19-8212-E675A99A65BA com.CapyCode.CapyCard
'

alias run_capycard_on_android='run_capy_card_on_android'


# --- OS Specific Aliases ---
if [[ "$(uname)" != "Darwin" ]]; then
    # WSL / Linux Clipboard Integration
    # Check for WSL specifically if needed, but clip.exe usually indicates WSL
    if command -v clip.exe &> /dev/null; then
        alias pbcopy='clip.exe'
        alias pbpaste='powershell.exe -noprofile -command Get-Clipboard'
    elif command -v xclip &> /dev/null; then
        # Fallback for pure Linux with X11
        alias pbcopy='xclip -selection clipboard -in'
        alias pbpaste='xclip -selection clipboard -out'
    fi
    
    # Open (macOS style)
    if command -v wslview &> /dev/null; then
        alias open='wslview'
    elif command -v xdg-open &> /dev/null; then
        alias open='xdg-open'
    else
        alias open='explorer.exe'
    fi
fi

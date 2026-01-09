## Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Setze den Pfad zu deinem Java SDK
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

# Setze den Pfad zu deinem Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Setze den Pfad zu deinem .NET SDK
export DOTNET_ROOT=/usr/local/share/dotnet
export PATH=$PATH:$DOTNET_ROOT

export PATH="$PATH:$HOME/.dotnet/tools"
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Tab accepts autosuggestion
bindkey '^I' autosuggest-accept

# Right arrow performs normal completion
bindkey '^[[Z' expand-or-complete

# ---- Eza (better ls) -----
alias ls="eza --icons=always -la"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"

export LANG=en_US.UTF-8

alias google='function _google() { local query=$(echo "$*" | sed "s/ /+/g"); open "https://www.google.com/search?q=$query"; }; _google'

alias openweb='function _openweb() { local url="https://$1"; open "$url"; }; _openweb'

alias python='python3'
alias pip='python3 -m pip'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias c='clear'
alias g='git'
alias gits='git status'
alias ga='git add'
alias ga.='git add .'
alias gc='git commit -m'
alias gcam='git commit -a -m'
alias gp='git push'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/simon/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/simon/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/simon/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/simon/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Turtlebot setup
export TURTLEBOT3_MODEL=burger
export ROS_DOMAIN_ID=70 # Für Kurs-WLAN / Roboter

export PATH="/Library/TeX/texbin:$PATH"

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

# Benenne die Funktion um, z.B. in fzfc
fzfc() {
  local -a files # Definiert files als Array
  # Füllt das Array files mit den von fzf ausgewählten Dateien (jede Zeile eine Datei)
  files=(${(f)"$(fzf -m --preview=\"bat --color=always {}\")"})

  # Prüft, ob Dateien ausgewählt wurden (fzf gibt bei Abbruch einen Fehlercode != 0)
  # und ob das Array files nicht leer ist.
  if [[ $? -eq 0 && ${#files[@]} -gt 0 ]]; then
    code -- "${files[@]}" # Öffnet alle ausgewählten Dateien in VS Code
                         # "${files[@]}" sorgt dafür, dass jede Datei als separates,
                         # korrekt gequotetes Argument übergeben wird.
  fi
}

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
  cd /Users/simon/CapyCode/CapyCard && \
  dotnet build CapyCard/CapyCard.iOS/CapyCard.iOS.csproj -f net9.0-ios && \
  (xcrun simctl boot 93967CA2-E319-4C19-8212-E675A99A65BA 2>/dev/null || true) && \
  open -a Simulator && \
  xcrun simctl install 93967CA2-E319-4C19-8212-E675A99A65BA CapyCard/CapyCard.iOS/bin/Debug/net9.0-ios/iossimulator-arm64/CapyCard.iOS.app && \
  xcrun simctl launch 93967CA2-E319-4C19-8212-E675A99A65BA com.CapyCode.CapyCard
'

run_capy_card_on_android() {
  # --- SETUP ---
  cd /Users/simon/CapyCode/CapyCard || return
  export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
  
  local PROJECT_PATH="CapyCard/CapyCard.Android/CapyCard.Android.csproj"
  local PACKAGE_NAME="com.CapyCode.CapyCard"
  
  # Emulator Config
  local EMU_AVD_NAME="Pixel_9_Pro_XL"
  local EMU_SERIAL="emulator-5554"

  # --- 1. ZIELGERÄT ERMITTELN ---
  local TARGET_SERIAL=""
  local PHYSICAL_DEVICE=$(adb devices | grep "\tdevice" | grep -v "emulator" | head -n 1 | cut -f1)

  if [ -n "$PHYSICAL_DEVICE" ]; then
      echo "📱 Physisches Gerät gefunden: $PHYSICAL_DEVICE"
      TARGET_SERIAL="$PHYSICAL_DEVICE"
  else
      echo "⚠️  Kein physisches Gerät gefunden. Prüfe Emulator..."
      if ! adb devices | grep -q "$EMU_SERIAL"; then
          echo "⏳ Starte Emulator ($EMU_AVD_NAME)..."
          emulator -avd "$EMU_AVD_NAME" > /dev/null 2>&1 &
          adb -s "$EMU_SERIAL" wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'
          echo "✅ Emulator bereit."
      else
          echo "✅ Emulator läuft bereits."
      fi
      TARGET_SERIAL="$EMU_SERIAL"
  fi

  echo "🎯 Ziel: $TARGET_SERIAL"
  echo "--------------------------------"

  # --- 2. UPDATE & INSTALLATION ---
  echo "💾 Installiere App (Daten bleiben erhalten)..."
  dotnet build "$PROJECT_PATH" -t:Install \
      -f net9.0-android \
      -r android-arm64 \
      -p:AndroidSerial="$TARGET_SERIAL"

  if [ $? -ne 0 ]; then
      echo "❌ Installation fehlgeschlagen."
      return 1
  fi

  # --- 3. START & LOGGING ---
  echo "🚀 Starte App..."
  
  # Alten Log-Puffer leeren (damit wir nur neue Fehler sehen)
  adb -s "$TARGET_SERIAL" logcat -c

  # App neu starten
  adb -s "$TARGET_SERIAL" shell am force-stop "$PACKAGE_NAME" > /dev/null 2>&1
  adb -s "$TARGET_SERIAL" shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
  
  echo "📝 App gestartet. Streame gefilterte Logs..."
  echo "   (Filter: [App], DotNet, Avalonia, AndroidRuntime)"
  echo "   Drücke Ctrl+C um das Loggen zu beenden."
  echo "---------------------------------------------------"

  # Hier ist der Filter-Magic:
  # -v color: Bunte Ausgabe
  # grep -E: Sucht nach MEHREREN Begriffen gleichzeitig
  # Wir suchen nach unserem "[App]" Prefix und kritischen System-Tags
  adb -s "$TARGET_SERIAL" logcat -v color | grep -E "\[WysiwygEditor\]|\[ClipboardAndroid\]|CapyCard"
}

export PATH=~/.npm-global/bin:$PATH
alias bouncai-env="source \"/Users/simon/Documents/TUBAF/WiSe-25_26/KI/.bouncai-env/bin/activate\""

# Load secrets if they exist
if [ -f "$HOME/.zshrc_secrets" ]; then
    source "$HOME/.zshrc_secrets"
fi


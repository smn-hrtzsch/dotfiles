# ---- Functions ----

# FZF with Preview for VS Code
fzfc() {
  local -a files
  files=(${(f)"$(fzf -m --preview=\"bat --color=always {}\")"})
  if [[ $? -eq 0 && ${#files[@]} -gt 0 ]]; then
    code -- "${files[@]}" 
  fi
}

# CapyCard Android Runner
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
  
  # Alten Log-Puffer leeren
  adb -s "$TARGET_SERIAL" logcat -c

  # App neu starten
  adb -s "$TARGET_SERIAL" shell am force-stop "$PACKAGE_NAME" > /dev/null 2>&1
  adb -s "$TARGET_SERIAL" shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
  
  echo "📝 App gestartet. Streame gefilterte Logs..."
  echo "   (Filter: [App], DotNet, Avalonia, AndroidRuntime)"
  echo "   Drücke Ctrl+C um das Loggen zu beenden."
  echo "---------------------------------------------------"

  adb -s "$TARGET_SERIAL" logcat -v color | grep -E "\[WysiwygEditor\]| \[ClipboardAndroid\]|CapyCard"
}

# System Update (Nix)
update-system() {
  local DOTFILES="$HOME/dotfiles"
  echo "🚀 Updating Dotfiles & System..."
  
  if [ -d "$DOTFILES" ]; then
    echo "📂 Switching to $DOTFILES"
    cd "$DOTFILES" || return
    
    echo "⬇️  Pulling latest changes..."
    if git pull; then
      echo "✅ Git pull successful."
    else
      echo "❌ Git pull failed. Please check for conflicts."
      return 1
    fi
    
    echo "⚙️  Rebuilding System..."
    if [[ "$(uname)" == "Darwin" ]]; then
       # macOS
       nix run nix-darwin -- switch --flake ./nix#macbook
    else
       # Linux / WSL
       nix run home-manager/master -- switch --flake ./nix#wsl
    fi
    
    # Update WezTerm Link (WSL only)
    if [[ "$(uname)" != "Darwin" && -f "$DOTFILES/scripts/link_wezterm.sh" ]]; then
       "$DOTFILES/scripts/link_wezterm.sh"
    fi

    echo "✅ Update Complete! Reloading shell..."
    # Replace current shell with a new one to fully load new env/config
    exec zsh
  else
    echo "❌ Dotfiles directory not found at $DOTFILES"
  fi
}

# Windows App Backup
backup-windows() {
  local DOTFILES="$HOME/dotfiles"
  echo "📦 Exporting Windows Apps (winget)..."
  mkdir -p "$DOTFILES/windows"
  powershell.exe -Command "winget export -o 'windows\packages.json' --source winget --accept-source-agreements"
  echo "✅ Done! Update saved to $DOTFILES/windows/packages.json"
}

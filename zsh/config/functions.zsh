# ---- Functions ----

# FZF with Preview for VS Code
fzfc() {
  local -a files
  files=(${(f)"$(fzf -m --preview=\"bat --color=always {}\")"})
  if [[ $? -eq 0 && ${#files[@]} -gt 0 ]]; then
    code -- "${files[@]}" 
  fi
}

# --- Rebuild Helpers ---
is_wsl() {
  if [[ -n "$WSL_DISTRO_NAME" ]]; then
    return 0
  fi
  if grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null && [ -d /mnt/c/Windows ]; then
    return 0
  fi
  return 1
}

rebuild_macos() {
  if ! command -v nix &>/dev/null; then
    if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
      . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
  fi
  local user_home="$HOME"
  local dr="/run/current-system/sw/bin/darwin-rebuild"
  local auto_host
  auto_host=$(scutil --get LocalHostName 2>/dev/null || hostname -s)
  local host="${DARWIN_HOST:-${auto_host:-MacBook-Air-von-Simon}}"
  if [ ! -x "$dr" ]; then
    dr="$(command -v darwin-rebuild)"
  fi
  sudo "$dr" switch --flake "$user_home/dotfiles/nix#$host"
}

rebuild_linux() {
  local arch
  local target
  arch=$(uname -m)
  target="linux-x86_64"
  if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
    target="linux-aarch64"
  fi
  nix run home-manager/master -- switch --flake "$HOME/dotfiles/nix#$target"
}

rebuild_wsl() {
  local arch
  local target
  arch=$(uname -m)
  target="wsl"
  if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
    target="wsl-aarch64"
  fi
  nix run home-manager/master -- switch --flake "$HOME/dotfiles/nix#$target"
}

rebuild_auto() {
  if [[ "$(uname)" == "Darwin" ]]; then
    rebuild_macos
  elif is_wsl; then
    rebuild_wsl
  else
    rebuild_linux
  fi
}

# CapyCard Android Runner
run_capy_card_on_android() {
  # --- SETUP ---
  cd "$HOME/CapyCode/CapyCard" || return

  if [[ "$(uname)" == "Darwin" ]]; then
      export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
      local ADB="adb"
  else
      # WSL/Linux
      local ADB="$HOME/Android/Sdk/platform-tools/adb"
  fi
  
  local PROJECT_PATH="CapyCard/CapyCard.Android/CapyCard.Android.csproj"
  local PACKAGE_NAME="com.CapyCode.CapyCard"
  local EMU_AVD_NAME="Pixel_9_Pro_XL"
  local EMU_SERIAL="emulator-5554"
  
  # Check Windows AVD availability if on WSL
  if [[ "$(uname)" != "Darwin" && -f "/mnt/c/Users/Simon/AppData/Local/Android/Sdk/emulator/emulator.exe" ]]; then
       if ! ls /mnt/c/Users/Simon/.android/avd/Pixel_9_Pro_XL.avd >/dev/null 2>&1; then
           if ls /mnt/c/Users/Simon/.android/avd/Pixel_8.avd >/dev/null 2>&1; then
               echo "ℹ️  'Pixel_9_Pro_XL' nicht gefunden. Nutze 'Pixel_8'."
               EMU_AVD_NAME="Pixel_8"
           fi
       fi
  fi

  # --- 1. VERBINDUNG PRÜFEN ---
  echo "🔍 Prüfe Verbindungen..."
  if [[ "$(uname)" != "Darwin" ]]; then
      # WSL: Proactive Connect
      $ADB connect 127.0.0.1:5555 >/dev/null 2>&1
      local HOST_IP=$(grep nameserver /etc/resolv.conf | cut -d ' ' -f2)
      $ADB connect "$HOST_IP:5555" >/dev/null 2>&1
  fi

  local TARGET_SERIAL=""
  local PHYSICAL_DEVICE=$($ADB devices | grep "\tdevice" | grep -v "emulator" | head -n 1 | cut -f1 | tr -d '\r')

  if [ -n "$PHYSICAL_DEVICE" ]; then
      echo "📱 Physisches Gerät gefunden: $PHYSICAL_DEVICE"
      TARGET_SERIAL="$PHYSICAL_DEVICE"
  else
      # Check if Emulator is already connected
      if $ADB devices | grep -q "$EMU_SERIAL"; then
          echo "✅ Emulator ($EMU_SERIAL) ist verbunden."
      else
          echo "⚠️  Emulator nicht gefunden. Starte neu..."
          
          if [[ "$(uname)" == "Darwin" ]]; then
              emulator -avd "$EMU_AVD_NAME" > /dev/null 2>&1 &
          else
              # WSL: Launch Windows Emulator
              local WIN_EMU="C:\Users\Simon\AppData\Local\Android\Sdk\emulator\emulator.exe"
              if [ -f "/mnt/c/Users/Simon/AppData/Local/Android/Sdk/emulator/emulator.exe" ]; then
                  echo "🖥️  Starte Windows-Emulator ($EMU_AVD_NAME)..."
                  powershell.exe -Command "Start-Process -FilePath '$WIN_EMU' -ArgumentList '-avd $EMU_AVD_NAME'" > /dev/null 2>&1
                  
                  # Connect Loop
                  echo "🔗 Warte auf Verbindung..."
                  for i in {1..20}; do
                      sleep 2
                      $ADB connect 127.0.0.1:5555 >/dev/null 2>&1
                      $ADB connect "$HOST_IP:5555" >/dev/null 2>&1
                      if $ADB devices | grep -q "$EMU_SERIAL"; then
                          echo "✅ Verbunden!"
                          break
                      fi
                  done
              else
                  echo "❌ Kein Windows-Emulator gefunden. Prüfe Linux-Emulator..."
                  "$HOME/Android/Sdk/emulator/emulator" -avd "$EMU_AVD_NAME" -gpu swiftshader_indirect > /dev/null 2>&1 &
              fi
          fi
          
          echo "⏳ Warte auf Boot..."
          $ADB -s "$EMU_SERIAL" wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'
      fi
      TARGET_SERIAL="$EMU_SERIAL"
  fi

  echo "🎯 Ziel: $TARGET_SERIAL"
  
  # Detect ABI with Retry
  local ABI=""
  for i in {1..5}; do
      ABI=$($ADB -s "$TARGET_SERIAL" shell getprop ro.product.cpu.abi | tr -d '\r')
      if [ -n "$ABI" ]; then break; fi
      sleep 1
  done
  
  echo "ℹ️  Geräte-Architektur: ${ABI:-UNBEKANNT}"
  
  local RUNTIME="android-arm64"
  if [[ "$ABI" == "x86_64" ]]; then
      RUNTIME="android-x64"
  elif [[ "$ABI" == "x86" ]]; then
      RUNTIME="android-x86"
  elif [[ -z "$ABI" ]]; then
      echo "⚠️  Konnte Architektur nicht erkennen. Versuche android-x64 (Emulator Standard)..."
      RUNTIME="android-x64"
  fi
  
  echo "⚙️  Nutze Runtime: $RUNTIME"
  echo "--------------------------------"

  # --- 2. UPDATE & INSTALLATION ---
  echo "💾 Installiere App..."
  # Explicitly pass adb path to dotnet just in case
  dotnet build "$PROJECT_PATH" -t:Install \
      -f net9.0-android \
      -r "$RUNTIME" \
      -p:AndroidSerial="$TARGET_SERIAL" \
      -p:AdbTarget="-s $TARGET_SERIAL"

  if [ $? -ne 0 ]; then
      echo "❌ Installation fehlgeschlagen."
      return 1
  fi

  # --- 3. START & LOGGING ---
  echo "🚀 Starte App..."
  $ADB -s "$TARGET_SERIAL" logcat -c
  $ADB -s "$TARGET_SERIAL" shell am force-stop "$PACKAGE_NAME" > /dev/null 2>&1
  $ADB -s "$TARGET_SERIAL" shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
  
  echo "📝 App gestartet. Logs:"
  $ADB -s "$TARGET_SERIAL" logcat -v color | grep -E "\[WysiwygEditor\]| \[ClipboardAndroid\]|CapyCard"
}

# System Update (Nix)
update-system() {
  local DOTFILES="$HOME/dotfiles"
  echo "🚀 Updating Dotfiles & System..."
  
  if [ -d "$DOTFILES" ]; then
    echo "📂 Switching to $DOTFILES"
    cd "$DOTFILES" || return

    if [[ -n "$DOTFILES_BRANCH" ]]; then
      if git diff --quiet && git diff --cached --quiet; then
        echo "🔀 Switching to branch: $DOTFILES_BRANCH"
        git fetch origin "$DOTFILES_BRANCH" || true
        git checkout "$DOTFILES_BRANCH" || true
      else
        echo "⚠️  Working tree has changes, skipping branch switch."
      fi
    fi
    
    echo "⬇️  Pulling latest changes..."
    if git pull; then
      echo "✅ Git pull successful."
    else
      echo "⚠️  Git pull failed (likely due to local changes). Proceeding with current local state..."
    fi

    if [ -f "$DOTFILES/.gitmodules" ]; then
      echo "🔁 Updating submodules..."
      git submodule update --init --recursive
    fi
    
    echo "⚙️  Rebuilding System..."
    rebuild_auto
    
    # Update WezTerm Link & Windows Apps (WSL only)
    if is_wsl; then
       if command -v powershell.exe >/dev/null 2>&1; then
          if [ -f "$DOTFILES/scripts/link_wezterm.sh" ]; then
             "$DOTFILES/scripts/link_wezterm.sh"
          fi
          # Automatically backup Windows Apps
          backup-windows
       else
          echo "⚠️  powershell.exe not found, skipping Windows integration steps."
       fi
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
  local TARGET="$DOTFILES/windows/packages.json"
  local TEMP_FILE="/tmp/packages_new.json"
  
  echo "📦 Exporting Windows Apps (winget)..."
  mkdir -p "$DOTFILES/windows"
  
  # Export to temp file, suppress warnings inside PowerShell and shell
  powershell.exe -Command "winget export -o '$TEMP_FILE' --source winget --accept-source-agreements > \$null 2>&1" >/dev/null 2>&1
  
  if [ -f "$TEMP_FILE" ]; then
    # Compare files while ignoring the line with "CreationDate"
    if [ ! -f "$TARGET" ] || ! diff -I '"CreationDate"' "$TARGET" "$TEMP_FILE" >/dev/null;
 then
      mv "$TEMP_FILE" "$TARGET"
      echo "✅ Done! Update saved to $TARGET"
    else
      rm "$TEMP_FILE"
      echo "✨ No package changes detected. Keeping existing $TARGET"
    fi
  else
    echo "❌ Failed to export Windows Apps."
  fi
}

# --- Clipboard Fix for Gemini CLI ---
# Enables Ctrl+V to paste from system clipboard.
# This is needed because we map Cmd+V -> Ctrl+V in Ghostty for image pasting in Gemini.
function paste-from-clipboard {
  if command -v pbpaste >/dev/null; then
    LBUFFER+=$(pbpaste)
  else
    # Fallback for Linux/WSL if needed later
    LBUFFER+=$(xclip -o -selection clipboard 2>/dev/null || wl-paste 2>/dev/null)
  fi
}
zle -N paste-from-clipboard
bindkey '^V' paste-from-clipboard

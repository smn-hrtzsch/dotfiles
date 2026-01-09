# ---- Exports & Paths ----

export LANG=en_US.UTF-8
export COLORTERM=truecolor

# Ensure system paths are always present (Fixes 'command not found' for coreutils)
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# NPM Global
[[ -d ~/.npm-global/bin ]] && export PATH="$HOME/.npm-global/bin:$PATH"

# Cargo
[[ -d ~/.cargo/bin ]] && export PATH="$HOME/.cargo/bin:$PATH"

# Turtlebot / ROS
export TURTLEBOT3_MODEL=burger
export ROS_DOMAIN_ID=70 

# --- macOS Specific Configs ---
if [[ "$(uname)" == "Darwin" ]]; then
    # Java (OpenJDK)
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    export JAVA_HOME="/opt/homebrew/opt/openjdk"
    export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

    # Android SDK
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

    # .NET SDK
    export DOTNET_ROOT=/usr/local/share/dotnet
    export PATH=$PATH:$DOTNET_ROOT
    export PATH="$PATH:$HOME/.dotnet/tools"

    # LaTeX
    export PATH="/Library/TeX/texbin:$PATH"
fi

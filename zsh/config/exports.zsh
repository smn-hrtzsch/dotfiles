# ---- Exports & Paths ----

export LANG=en_US.UTF-8

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

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

# NPM Global
export PATH=~/.npm-global/bin:$PATH

# Turtlebot / ROS
export TURTLEBOT3_MODEL=burger
export ROS_DOMAIN_ID=70 

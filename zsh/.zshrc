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

# Python 3.9
# export PATH="/opt/homebrew/opt/python@3.9/libexec/bin":$PATH

# Setze den Pfad zu deinem Java SDK
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
export PATH="$JAVA_HOME/bin:$PATH"

# Setze den Pfad zu deinem Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Setze den Pfad zu deinem .NET SDK
export DOTNET_ROOT=usr/local/share/dotnet/sdk
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
export ROS_DOMAIN_ID=50 # Für Kurs-WLAN / Roboter

# ROS 2 Workspace sourcen
ROS2_SETUP_FILE="$HOME/ros2_ws/install/local_setup.zsh"
if [ -f "$ROS2_SETUP_FILE" ]; then
  # shellcheck disable=SC1090 # Disable warning about non-constant source path
  source "$ROS2_SETUP_FILE"
fi
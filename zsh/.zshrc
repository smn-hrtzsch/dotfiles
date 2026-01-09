## Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---- Plugins & Theme ----
# Source Homebrew plugins only if they exist (for non-Nix setups)
[[ ! -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]] || source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] || source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ ! -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] || source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---- Zsh Options & History ----
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# ---- Keybindings ----
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^I' autosuggest-accept
bindkey '^[[Z' expand-or-complete

# ---- Tools Init ----
eval "$(pyenv init -)"
eval "$(zoxide init zsh)"

# Direnv hook (if installed)
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
# ---- Tools Init (Managed by Nix) ----
# Nix automatically sources necessary init scripts for zoxide, direnv, etc.

# Add NPM global binaries to PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# ---- Load Modular Config ----
# Loads all .zsh files from ~/dotfiles/zsh/config/
if [ -d "$HOME/dotfiles/zsh/config" ]; then
    for config_file in "$HOME/dotfiles/zsh/config/"*.zsh; do
        source "$config_file"
    done
fi

# ---- Conda Initialize ----
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

# ---- Load Secrets ----
# Load secrets if they exist (last to override anything if necessary)
if [ -f "$HOME/.zshrc_secrets" ]; then
    source "$HOME/.zshrc_secrets"
fi
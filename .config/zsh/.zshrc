#!/bin/zsh
# shellcheck shell=bash source=/dev/null disable=SC2034

[[ -s "$HOME/.cache/p10k-instant-prompt-${%:-%n}.zsh" ]] && source "$HOME/.cache/p10k-instant-prompt-${%:-%n}.zsh"

setopt HIST_IGNORE_ALL_DUPS # Remove older command from the history if a duplicate is to be added.

bindkey -v # Set editor default keymap to vi (`-v`)
zmodload -F zsh/terminfo +p:terminfo
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

ZSH_AUTOSUGGEST_MANUAL_REBIND=1
bindkey '^l' autosuggest-accept
bindkey '^h' autosuggest-clear

POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
[[ -s "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

export ZIM_HOME="$HOME/.local/share/zim"
export ZIM_CONFIG_FILE="$ZDOTDIR/.zimrc"
[[ -e "$ZIM_HOME/zimfw.zsh" ]] || \
  curl -fsSL --create-dirs -o "${ZIM_HOME}/zimfw.zsh" "https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh" # Download zim if missing
[[ -s "$ZIM_HOME/zimfw.zsh" ]] && source "$ZIM_HOME/zimfw.zsh" init -q # Install modules and update Zim # Define zmodule
[[ -s "$ZIM_HOME/init.zsh" ]] && source "$ZIM_HOME/init.zsh" # Source Zim

NVM_DIR="$HOME/.local/share/nvm"
NVM_COMPLETION=true
NVM_LAZY_LOAD=true
NVM_LAZY_LOAD_EXTRA_COMMANDS=(nvm node npm npx yarn nvim vim)
[[ -s "$HOME/.local/share/zsh-nvm/zsh-nvm.plugin.zsh" ]] && source "$HOME/.local/share/zsh-nvm/zsh-nvm.plugin.zsh"

[[ -f "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

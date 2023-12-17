#!/bin/bash
# shellcheck shell=bash source=/dev/null

[[ $- != *i* ]] && return # if not running interactively, don't do anything

HISTCONTROL=ignoreboth # don't put duplicate lines or lines starting with space in the history.
shopt -s histappend    # Append to the Bash history file, rather than overwriting it
HISTSIZE=1000          # number of lines of history to store in memory
HISTFILESIZE=10000     # number of lines of history to store in the history file

[[ $DISPLAY ]] && shopt -s checkwinsize

[[ -r "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

# vim:fdm=indent

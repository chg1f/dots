#!/bin/bash
# shellcheck shell=bash

alias more='less'
alias la='ls -AF'
alias l='la -C'
alias ll='la -l'
alias rm='rm -i -v' # confirm before removing something
alias cp="cp -i"    # confirm before overwriting something
alias rg='rg --color=auto'
case "$(uname)" in
Darwin)
  alias ls='ls -G'
  alias grep='grep -G'
  alias fgrep='fgrep -G'
  ;;
Linux)
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias diff='diff --color=auto'
  alias ip='ip --color=auto'
  alias rm='rm --preserve-root'
  ;;
esac
alias px='SOCKS_PROXY="socks5://127.0.0.1:1080" HTTP_PROXY="http://127.0.0.1:8118" HTTPS_PROXY="http://127.0.0.1:8118" ALL_PROXY="socks5://127.0.0.1:1080"'

#!/bin/sh
# shellcheck shell=sh source=/dev/null

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"

export LANG="${LANG:-en_US.UTF-8}"
#export LC_ALL="${LC_ALL:-en_US.UTF-8}"

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  TERM="screen-256color"
elif [ -n "$TMUX" ]; then
  TERM="tmux-256color"
fi
case "$TERM" in
*color)
  export PS1=' \[\e[0;32m\]\]\u\[\e[0m\]\]@\[\e[0;35m\]\]\h\[\e[0m\]\]:\[\e[0;34m\]\]\w'
  ;;
*)
  export PS1=' \u@\h:\w \$ '
  ;;
esac

if command -v less >/dev/null 2>&1; then
  export PAGER="less"
  #export LESS="-RFX"
  export LESS='-g -i -M -R -S -w -X -z-4'
  if command -v src-hilite-lesspipe.sh >/dev/null 2>&1; then
    LESSPIPE="$(which src-hilite-lesspipe.sh)"
    export LESSOPEN="| ${LESSPIPE} %s"
  fi
fi
if command -v nvim >/dev/null 2>&1; then
  export VISUAL="nvim"
  export EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
  export VISUAL="vim"
  export EDITOR="vim"
elif command -v vi >/dev/null 2>&1; then
  export VISUAL="vi"
  export EDITOR="vi"
fi

if command -v tmux >/dev/null 2>&1; then
  if [ -z "$TMUX" ] && [ -n "$SSH_TTY" ]; then
    tmux attach -t ssh || tmux new -s ssh
  fi
fi

#
# alias PX="HTTP_PROXY=http://127.0.0.1:7890 HTTPS_PROXY=http://127.0.0.1:7890 SOCKS_PROXY=socks5://127.0.1:7890 ALL_PROXY=socks5://127.0.0.1:7890"
#
# # if command -v keychain >/dev/null 2>&1; then
# #   eval "$(keychain --eval --quiet --timeout 60)"
# # fi
# #
# # export GIT_PS1_SHOWDIRTYSTATE=yes
# # export GIT_PS1_SHOWSTASHSTATE=yes
# # export GIT_PS1_SHOWUNTRACKEDFILES=yes
# # export GIT_PS1_SHOWUPSTREAM=verbose
# # export GIT_PS1_OMITSPARSESTATE=yes
# # export GIT_PS1_DESCRIBE_STYLE=describe
# # export GIT_PS1_HIDE_IF_PWD_IGNORED=yes
# #
# # export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# # if command -v fd >/dev/null 2>&1; then
# #   export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
# # elif command -v rg >/dev/null 2>&1; then
# #   export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
# # fi
# # export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# # export FZF_CTRL_R_OPTS='--preview "echo {}" --preview-window down:3:hidden:wrap'
# # export FZF_CTRL_T_OPTS='--preview "echo {}" --preview-window down:3:hidden:wrap'
# # export FZF_ALT_C_OPTS='--preview "echo {}" --preview-window down:3:hidden:wrap'
# #
# # export PYTHONIOENCODING='UTF-8'
# #
# if command -v pyenv >/dev/null 2>&1; then
#   eval "$(pyenv init -)"
#   if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
#     eval "$(pyenv virtualenv-init -)"
#   fi
# fi
# [ -f "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
# [ -f "$HOME/.gvm/scripts/gvm" ] && . "$HOME/.gvm/scripts/gvm"
#
# #[ -f "$(brew --prefix)/opt/git/etc/bash_completion.d/git-prompt.sh" ] && . "$(brew --prefix)/opt/git/etc/bash_completion.d/git-prompt.sh"
# #[ -f "/usr/share/git/completion/git-prompt.sh" ] && . "/usr/share/git/completion/git-prompt.sh"
# ## [ -f "/usr/local/opt/git/etc/bash_completion.d/git-completion.bash" ] && . "/usr/local/opt/git/etc/bash_completion.d/git-completion.bash" ||
# ##   [ -f "/usr/share/git/completion/git-completion.bash" ] && . "/usr/share/git/completion/git-completion.bash"
# #unset -f insert_path
# ## vim:fdm=indent

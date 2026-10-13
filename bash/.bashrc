# ~/.bashrc
[[ $- != *i* ]] && return

alias code="antigravity-ide"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias py='python'
alias wifi='nmtui'
PS1='[\u@\h \W]\$ '

export PATH=$PATH:$HOME/.spicetify

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

. "$HOME/.local/bin/env"

# ~/.zshrc

# --- Historial ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY
setopt AUTO_CD INTERACTIVE_COMMENTS

# --- Completado ---
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit -C
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# --- Teclas ---
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# --- Plugins (paquetes de Arch) ---
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# syntax-highlighting siempre al final de los plugins
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Herramientas ---
export PATH=$PATH:$HOME/.spicetify
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
command -v fzf >/dev/null && source <(fzf --zsh)
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

# nvm en modo lazy (cargarlo siempre hace lento el arranque)
export NVM_DIR="$HOME/.nvm"
_nvm_lazy() {
    unset -f nvm node npm npx 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
for _c in nvm node npm npx; do eval "$_c() { _nvm_lazy; $_c \"\$@\"; }"; done
unset _c

# --- Aliases ---
alias code="antigravity-ide"
alias py='python'
alias wifi='nmtui'
alias grep='grep --color=auto'
if command -v eza >/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --git'
    alias la='eza -la --icons --group-directories-first --git'
    alias lt='eza --tree --level=2 --icons'
else
    alias ls='ls --color=auto'
fi
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'
alias theme='~/.config/hypr/scripts/theme.sh'
alias wall='~/.config/hypr/scripts/wallpaper.sh'

# --- Prompt ---
command -v starship >/dev/null && eval "$(starship init zsh)"

# --- fastfetch con el logo del perfil activo ---
ff() {
    local prof logo
    prof=$(cat ~/.cache/wallpaper/profile 2>/dev/null)
    logo=~/.config/fastfetch/logos/${prof}.txt
    if [[ -f $logo ]]; then
        fastfetch --logo "$logo" --logo-type file --logo-color-1 magenta --logo-color-2 blue --logo-padding-right 3 "$@"
    else
        fastfetch "$@"
    fi
}
# al abrir una terminal nueva (solo una vez por terminal)
if [[ -o interactive && -z "$FASTFETCH_SHOWN" && "$TERM" == xterm-kitty ]]; then
    export FASTFETCH_SHOWN=1
    command -v fastfetch >/dev/null && ff
fi

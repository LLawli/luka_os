# Luka DX aliases and helpers
# Only load for interactive shells

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

# Remove defaults we want to override
unalias ls 2>/dev/null
unalias ll 2>/dev/null
unalias cat 2>/dev/null
unalias g 2>/dev/null
unalias v 2>/dev/null

# Editor / git
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias g='git'

# File listing with eza
alias ls='eza'
alias l='eza -lah --group-directories-first'
alias la='eza -a --group-directories-first'
alias ll='eza -lh --group-directories-first'
alias lt='eza --tree'
alias lta='eza --tree -a'
alias lx='eza -lah --git --group-directories-first'

# File viewing
alias cat='bat'
alias c='clear'

# Fast search tools
alias r='rg'
alias ri='rg -i'
alias rf='rg --fixed-strings'
alias ff='fd'
alias ffd='fd --type d'
alias fff='fd --type f'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Git helpers
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -n 20'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gco='git checkout'
alias gsw='git switch'
alias gswc='git switch -c'
alias gpl='git pull'
alias gcl='git clone'

# Containers
alias d='docker'
alias dc='docker compose'
alias p='podman'
alias pc='podman compose'
alias pi='podman images'
alias pp='podman ps'
alias ppa='podman ps -a'

# System tools
alias j='just'
alias lg='lazygit'
alias bt='btop'
alias du1='du -h --max-depth=1'

# Safety prompts for interactive use
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Functions

# Create directory and enter it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Fuzzy jump using zoxide database
cdf() {
  local dir
  dir="$(zoxide query -l | fzf --height 40% --reverse --border --prompt='jump > ')" || return
  [ -n "$dir" ] && cd "$dir"
}

# Fuzzy open file in nvim
cff() {
  local file
  file="$(fd . --type f --hidden --follow \
    --exclude .git \
    --exclude node_modules \
    --exclude dist \
    --exclude build \
    2>/dev/null | fzf --height 40% --reverse --border --prompt='file > ')" || return
  [ -n "$file" ] && nvim "$file"
}

# Fuzzy kill process
fkill() {
  local pid
  pid="$(ps -ef | sed 1d | fzf --height 40% --reverse --border --prompt='kill > ' | awk '{print $2}')" || return
  [ -n "$pid" ] && kill -9 "$pid"
}

# Extract common archive types
extract() {
  if [ -z "${1:-}" ]; then
    echo "usage: extract <archive>"
    return 1
  fi

  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.tar.bz2) tar xjf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.gz) gunzip "$1" ;;
    *.xz) unxz "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.zip) unzip "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "Unsupported archive format: $1" ;;
  esac
}

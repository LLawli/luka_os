# Luka shell config
# Only load for interactive shells
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

# ── editor ────────────────────────────────────────────────────────────────────
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# ── git ───────────────────────────────────────────────────────────────────────
alias g='git'
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

# ── eza: powers ls ───────────────────────────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
  unalias ls ll la 2>/dev/null
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --group-directories-first --git'
  alias la='eza -lah --group-directories-first --git'
  alias lt='eza --tree'
  alias lta='eza --tree -a --ignore-glob=".git"'
fi

# ── ripgrep ───────────────────────────────────────────────────────────────────
if command -v rg >/dev/null 2>&1; then
  alias r='rg'
  alias ri='rg -i'
  alias rf='rg --fixed-strings'
fi

# ── fd: short alias ──────────────────────────────────────────────────────────
if command -v fd >/dev/null 2>&1; then
  alias f='fd'
  alias ffd='fd --type d'
  alias fff='fd --type f'
fi

# ── dust: powers du ──────────────────────────────────────────────────────────
if command -v dust >/dev/null 2>&1; then
  alias du='dust'
fi

# ── procs: powers ps ─────────────────────────────────────────────────────────
if command -v procs >/dev/null 2>&1; then
  alias ps='procs'
fi

# ── xcp: powers cp ───────────────────────────────────────────────────────────
if command -v xcp >/dev/null 2>&1; then
  alias cp='xcp'
fi

# ── xh: powers http/https ────────────────────────────────────────────────────
if command -v xh >/dev/null 2>&1; then
  alias http='xh'
  alias https='xh --https'
fi

# ── tldr: powers man ─────────────────────────────────────────────────────────
if command -v tldr >/dev/null 2>&1; then
  alias man='tldr'
fi

# ── containers ───────────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias p='podman'
alias pc='podman compose'
alias pi='podman images'
alias pp='podman ps'
alias ppa='podman ps -a'

# ── system tools ─────────────────────────────────────────────────────────────
alias j='just'
alias lg='lazygit'
alias ldk='lazydocker'
alias bt='btop'
alias c='clear'
alias y='yazi'
alias md='glow'

# ── navigation ────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ── safety ───────────────────────────────────────────────────────────────────
alias mv='mv -i'
alias rm='rm -i'

# ── cdf: cd + fzf fuzzy jump ─────────────────────────────────────────────────
if command -v fzf >/dev/null 2>&1 && command -v zoxide >/dev/null 2>&1; then
  cdf() {
    local dir
    dir="$(zoxide query -l | fzf --height 40% --reverse --border --prompt='jump > ')" || return
    [ -n "$dir" ] && cd "$dir"
  }
fi

# ── cff: fuzzy open file in nvim ─────────────────────────────────────────────
if command -v fzf >/dev/null 2>&1 && command -v fd >/dev/null 2>&1; then
  cff() {
    local file
    file="$(fd . --type f --hidden --follow \
      --exclude .git --exclude node_modules --exclude dist --exclude build \
      2>/dev/null | fzf --height 40% --reverse --border --prompt='file > ')" || return
    [ -n "$file" ] && nvim "$file"
  }
fi

# ── fkill: fuzzy kill process ────────────────────────────────────────────────
if command -v fzf >/dev/null 2>&1; then
  fkill() {
    local pid
    pid="$(ps -ef | sed 1d | fzf --height 40% --reverse --border --prompt='kill > ' | awk '{print $2}')" || return
    [ -n "$pid" ] && kill -9 "$pid"
  }
fi

# ── mkcd: create dir and enter it ────────────────────────────────────────────
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# ── extract: descompacta qualquer formato ────────────────────────────────────
extract() {
  if [ -z "${1:-}" ]; then
    echo "usage: extract <arquivo>"
    return 1
  fi
  if ! [ -f "$1" ]; then
    echo "extract: '$1' não é um arquivo"
    return 1
  fi

  if command -v ouch >/dev/null 2>&1; then
    ouch decompress "$1"
    return
  fi

  case "$1" in
    *.tar.gz|*.tgz)   tar xzf "$1"  ;;
    *.tar.xz)         tar xJf "$1"  ;;
    *.tar.bz2)        tar xjf "$1"  ;;
    *.tar.zst)        tar --zstd -xf "$1" ;;
    *.tar)            tar xf  "$1"  ;;
    *.gz)             gunzip  "$1"  ;;
    *.xz)             unxz    "$1"  ;;
    *.bz2)            bunzip2 "$1"  ;;
    *.zst)            zstd -d "$1"  ;;
    *.zip)            unzip   "$1"  ;;
    *.7z)             7z x    "$1"  ;;
    *.rar)            unrar x "$1"  ;;
    *)
      echo "extract: formato não reconhecido: $1"
      return 1
      ;;
  esac
}

# Luka zsh config — loaded for interactive zsh shells

# Source profile.d if not already loaded (login shells get this via /etc/profile)
if [[ -z "$PROFILEREAD" ]]; then
  for _f in /etc/profile.d/*.sh; do
    [[ -r "$_f" ]] && source "$_f"
  done
  unset _f
fi

# ── history ───────────────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# ── options ───────────────────────────────────────────────────────────────────
setopt AUTO_CD            # type dir name to cd into it
setopt HIST_IGNORE_DUPS   # no consecutive duplicates in history
setopt HIST_IGNORE_SPACE  # commands starting with space not saved
setopt SHARE_HISTORY      # share history between sessions
setopt CORRECT            # suggest corrections for typos
setopt COMPLETE_IN_WORD   # complete from cursor position
setopt GLOB_DOTS          # include dotfiles in glob patterns
setopt NO_BEEP            # no beeping

# ── completion ────────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit -C  # -C skips the security check for speed (cache)

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive

# ── key bindings ──────────────────────────────────────────────────────────────
bindkey '^[[A' history-search-backward   # up arrow
bindkey '^[[B' history-search-forward    # down arrow
bindkey '^[^[[C' forward-word            # alt+right
bindkey '^[^[[D' backward-word           # alt+left

# ── tool hooks (after compinit so compdef is available) ───────────────────────
command -v direnv   >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v atuin    >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"
command -v carapace >/dev/null 2>&1 && source <(carapace _carapace zsh)
command -v thefuck  >/dev/null 2>&1 && eval "$(thefuck --alias)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ── zsh plugins ───────────────────────────────────────────────────────────────
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── zoxide (last so cd alias is not overridden by other inits) ────────────────
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
  alias zz='zi'
fi

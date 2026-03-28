# Starship prompt init — bash only; zsh is handled in /etc/zshrc.d/50-luka.zsh
[ -n "${BASH_VERSION:-}" ] || return 0 2>/dev/null
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

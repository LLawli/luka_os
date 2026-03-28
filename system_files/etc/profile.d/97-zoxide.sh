# Initialize zoxide — bash only; zsh is handled in /etc/zshrc.d/50-luka.zsh
[ -n "${BASH_VERSION:-}" ] || return 0 2>/dev/null
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash --cmd cd)"

# Optional shortcut for fuzzy directory jump
alias zz='zi'

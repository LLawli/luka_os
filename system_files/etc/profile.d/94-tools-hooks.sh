# Tool shell hooks: direnv, atuin, carapace, thefuck
# Bash only — zsh hooks are in /etc/zshrc.d/50-luka.zsh
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

[ -z "${BASH_VERSION:-}" ] && return
[ -n "$_LUKA_BASH_HOOKS_LOADED" ] && return
export _LUKA_BASH_HOOKS_LOADED=1

command -v direnv   >/dev/null 2>&1 && eval "$(direnv hook bash)"
command -v atuin    >/dev/null 2>&1 && eval "$(atuin init bash --disable-up-arrow)"
command -v carapace >/dev/null 2>&1 && source <(carapace _carapace bash)
command -v thefuck  >/dev/null 2>&1 && eval "$(thefuck --alias)"

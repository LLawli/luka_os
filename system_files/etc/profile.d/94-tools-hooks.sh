# Tool shell hooks: direnv, atuin, carapace
# Loaded for both bash and zsh (shell-aware)
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

[ -n "$_LUKA_HOOKS_LOADED" ] && return
export _LUKA_HOOKS_LOADED=1

if [ -n "${ZSH_VERSION:-}" ]; then
  _luka_shell=zsh
elif [ -n "${BASH_VERSION:-}" ]; then
  _luka_shell=bash
fi

# ── direnv ────────────────────────────────────────────────────────────────────
if command -v direnv >/dev/null 2>&1 && [ -n "${_luka_shell:-}" ]; then
  eval "$(direnv hook "$_luka_shell")"
fi

# ── atuin ─────────────────────────────────────────────────────────────────────
if command -v atuin >/dev/null 2>&1 && [ -n "${_luka_shell:-}" ]; then
  eval "$(atuin init "$_luka_shell" --disable-up-arrow)"
fi

# ── carapace ──────────────────────────────────────────────────────────────────
if command -v carapace >/dev/null 2>&1 && [ -n "${_luka_shell:-}" ]; then
  if [ "$_luka_shell" = "zsh" ]; then
    source <(carapace _carapace zsh)
  elif [ "$_luka_shell" = "bash" ]; then
    source <(carapace _carapace bash)
  fi
fi

unset _luka_shell

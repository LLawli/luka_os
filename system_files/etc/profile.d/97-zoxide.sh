# Initialize zoxide and make it power the cd command

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd cd)"
fi

# Optional shortcut for fuzzy directory jump
alias zz='zi'

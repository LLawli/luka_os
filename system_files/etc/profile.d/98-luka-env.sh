# Environment defaults for Luka DX shell

export EDITOR=nvim
export VISUAL=nvim

# Pretty manpages using bat
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# Better less behavior
export LESS="-R"

# History settings
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth

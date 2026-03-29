# Environment defaults for Luka DX shell

export EDITOR=nvim
export VISUAL=nvim
export SUDO_EDITOR=nvim

# Man pages with neovim + treesitter syntax highlighting
export MANPAGER='nvim +Man!'
export MANWIDTH=999

export STARSHIP_CONFIG=/etc/starship.toml

# Better less behavior
export LESS="-R"

# History settings
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth

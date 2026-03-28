#!/bin/bash

set -ouex pipefail

### Extra repos
dnf5 -y copr enable dejan/lazygit

### Install packages
dnf5 install -y \
    bat \
    btop \
    eza \
    fd-find \
    fzf \
    jq \
    procs \
    ripgrep \
    tealdeer \
    yq \
    zoxide \
    tmux git gh neovim \
    tree unzip wget curl rsync lsof strace shellcheck direnv \
    gcc-c++ clang make cmake ninja-build pkgconf-pkg-config openssl-devel sqlite-devel zlib-devel libffi-devel \
    podman podman-docker podman-compose buildah skopeo \
    age tree-sitter lazygit \
    p7zip p7zip-plugins unrar \
    mtr nmap netcat tcpdump \
    htop iotop ncdu entr progress hyperfine ltrace perf tailscale bind-utils sqlite openssl \
    zsh atuin yazi

### Disable extra repos after install
dnf5 -y copr disable dejan/lazygit

### Install tools from GitHub releases
# (not yet available in Fedora repos or need newer versions)

ARCH="x86_64"
INSTALL_DIR="/usr/bin"
GHREL=$(mktemp -d)
trap 'rm -rf "$GHREL"' EXIT

gh_latest() {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
        | grep '"tag_name"' | head -1 | cut -d'"' -f4
}

# delta — git diff viewer
DELTA_VER=$(gh_latest "dandavison/delta")
curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VER}/delta-${DELTA_VER#v}-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/delta-${DELTA_VER#v}-${ARCH}-unknown-linux-musl/delta" "$INSTALL_DIR/delta"

# dust — disk usage (du alternative)
DUST_VER=$(gh_latest "bootandy/dust")
curl -fsSL "https://github.com/bootandy/dust/releases/download/${DUST_VER}/dust-${DUST_VER}-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/dust-${DUST_VER}-${ARCH}-unknown-linux-musl/dust" "$INSTALL_DIR/dust"

# ouch — universal archive tool
OUCH_VER=$(gh_latest "ouch-org/ouch")
curl -fsSL "https://github.com/ouch-org/ouch/releases/download/${OUCH_VER}/ouch-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/ouch-${ARCH}-unknown-linux-musl/ouch" "$INSTALL_DIR/ouch"

# sd — sed alternative
SD_VER=$(gh_latest "chmln/sd")
curl -fsSL "https://github.com/chmln/sd/releases/download/${SD_VER}/sd-${SD_VER}-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/sd-${SD_VER}-${ARCH}-unknown-linux-musl/sd" "$INSTALL_DIR/sd"

# watchexec — file watcher / task runner
WATCHEXEC_VER=$(gh_latest "watchexec/watchexec")
curl -fsSL "https://github.com/watchexec/watchexec/releases/download/${WATCHEXEC_VER}/watchexec-${WATCHEXEC_VER#v}-${ARCH}-unknown-linux-musl.tar.xz" \
    | tar -xJ -C "$GHREL"
install -m755 "$GHREL/watchexec-${WATCHEXEC_VER#v}-${ARCH}-unknown-linux-musl/watchexec" "$INSTALL_DIR/watchexec"

# xh — HTTP client (httpie alternative)
XH_VER=$(gh_latest "ducaale/xh")
curl -fsSL "https://github.com/ducaale/xh/releases/download/${XH_VER}/xh-${XH_VER}-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/xh-${XH_VER}-${ARCH}-unknown-linux-musl/xh" "$INSTALL_DIR/xh"

# xcp — cp with progress (tag has "xcp-" prefix, gnu only)
XCP_VER=$(gh_latest "tarka/xcp")
XCP_VER_CLEAN="${XCP_VER#xcp-}"
curl -fsSL "https://github.com/tarka/xcp/releases/download/${XCP_VER}/xcp-${XCP_VER_CLEAN}-${ARCH}-unknown-linux-gnu.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/xcp-${XCP_VER_CLEAN}-${ARCH}-unknown-linux-gnu/bin/xcp" "$INSTALL_DIR/xcp"

# xsv — CSV toolkit
XSV_VER=$(gh_latest "BurntSushi/xsv")
curl -fsSL "https://github.com/BurntSushi/xsv/releases/download/${XSV_VER}/xsv-${XSV_VER}-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/xsv" "$INSTALL_DIR/xsv"

# zellij — terminal multiplexer
ZELLIJ_VER=$(gh_latest "zellij-org/zellij")
curl -fsSL "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VER}/zellij-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/zellij" "$INSTALL_DIR/zellij"

# pipr — interactive shell pipeline builder
PIPR_VER=$(gh_latest "elkowar/pipr")
curl -fsSL "https://github.com/elkowar/pipr/releases/download/${PIPR_VER}/pipr" \
    -o "$GHREL/pipr"
install -m755 "$GHREL/pipr" "$INSTALL_DIR/pipr"

# starship — cross-shell prompt
STARSHIP_VER=$(gh_latest "starship/starship")
curl -fsSL "https://github.com/starship/starship/releases/download/${STARSHIP_VER}/starship-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/starship" "$INSTALL_DIR/starship"

# ripsecrets — secret scanner (gnu only)
RIPSECRETS_VER=$(gh_latest "sirwart/ripsecrets")
RIPSECRETS_VER_CLEAN="${RIPSECRETS_VER#v}"
curl -fsSL "https://github.com/sirwart/ripsecrets/releases/download/${RIPSECRETS_VER}/ripsecrets-${RIPSECRETS_VER_CLEAN}-${ARCH}-unknown-linux-gnu.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/ripsecrets-${RIPSECRETS_VER_CLEAN}-${ARCH}-unknown-linux-gnu/ripsecrets" "$INSTALL_DIR/ripsecrets"

# glow — markdown renderer
GLOW_VER=$(gh_latest "charmbracelet/glow")
curl -fsSL "https://github.com/charmbracelet/glow/releases/download/${GLOW_VER}/glow_${GLOW_VER#v}_Linux_x86_64.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/glow" "$INSTALL_DIR/glow"

# carapace — shell completions
CARAPACE_VER=$(gh_latest "carapace-sh/carapace-bin")
curl -fsSL "https://github.com/carapace-sh/carapace-bin/releases/download/${CARAPACE_VER}/carapace_${CARAPACE_VER#v}_linux_amd64.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/carapace" "$INSTALL_DIR/carapace"

# lazydocker — docker/podman TUI
LAZYDOCKER_VER=$(gh_latest "jesseduffield/lazydocker")
curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/${LAZYDOCKER_VER}/lazydocker_${LAZYDOCKER_VER#v}_Linux_x86_64.tar.gz" \
    | tar -xz -C "$GHREL"
install -m755 "$GHREL/lazydocker" "$INSTALL_DIR/lazydocker"

### Services
systemctl enable podman.socket
systemctl enable tailscaled
systemctl enable set-zsh-default

### Ensure zshrc.d directory exists
mkdir -p /etc/zshrc.d

### Remove default alias scripts that conflict with custom aliases
rm -f /etc/profile.d/colorls.sh /etc/profile.d/colorgrep.sh
rm -f /etc/profile.d/colorls.csh /etc/profile.d/colorgrep.csh

### Cleanup
dnf5 clean all

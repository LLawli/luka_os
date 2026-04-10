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
    librsvg2-tools \
    gcc-c++ clang make cmake ninja-build pkgconf-pkg-config openssl-devel sqlite-devel zlib-devel libffi-devel \
    podman podman-compose buildah skopeo \
    age tree-sitter lazygit \
    p7zip p7zip-plugins unrar \
    mtr nmap netcat tcpdump \
    htop iotop ncdu entr progress hyperfine ltrace perf tailscale bind-utils sqlite openssl radeontop \
    zsh atuin \
    zsh-autosuggestions zsh-syntax-highlighting \
    thefuck

### Disable extra repos after install
dnf5 -y copr disable dejan/lazygit

### Docker official repo
curl -fsSL https://download.docker.com/linux/fedora/docker-ce.repo \
    -o /etc/yum.repos.d/docker-ce.repo

### Install real Docker
dnf5 install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

### Install tools from GitHub releases
# (not yet available in Fedora repos or need newer versions)

ARCH="x86_64"
INSTALL_DIR="/usr/bin"
GHREL=$(mktemp -d)
trap 'rm -rf "$GHREL"' EXIT

gh_latest() {
    local token
    token=$(cat /run/secrets/github_token 2>/dev/null || true)
    if [ -n "$token" ]; then
        curl -fsSL -H "Authorization: Bearer ${token}" \
            "https://api.github.com/repos/$1/releases/latest" \
            | grep '"tag_name"' | head -1 | cut -d'"' -f4
    else
        curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
            | grep '"tag_name"' | head -1 | cut -d'"' -f4
    fi
}

# Find the first release asset name matching a pattern.
# Usage: gh_asset <owner/repo> <tag> <grep-pattern>
gh_asset() {
    local token
    token=$(cat /run/secrets/github_token 2>/dev/null || true)
    if [ -n "$token" ]; then
        curl -fsSL -H "Authorization: Bearer ${token}" \
            "https://api.github.com/repos/$1/releases/tags/$2"
    else
        curl -fsSL "https://api.github.com/repos/$1/releases/tags/$2"
    fi | jq -r '.assets[].name' | grep -E "$3" | head -1
}

# Download an archive and verify its SHA256 checksum.
# sha_url may point to a multi-entry "HASH  filename" sha256sums file
# or a single-hash file (just the hex string on the first line).
# If sha_url returns 404 or no valid hash is found, prints a warning and continues.
dl_verify() {
    local archive="$1" url="$2" sha_url="$3"
    local name
    name="$(basename "$url")"
    curl -fsSL -o "$archive" "$url"
    local raw hash
    raw=$(curl -sSL "$sha_url" 2>/dev/null || true)
    hash=$(printf '%s\n' "$raw" | awk -v n="$name" 'index($0,n){print $1; exit}')
    if [ -z "$hash" ]; then
        hash=$(printf '%s\n' "$raw" | awk 'NR==1{print $1}')
    fi
    if [ "${#hash}" -eq 64 ]; then
        printf '%s  %s\n' "$hash" "$archive" | sha256sum --check
    else
        printf 'WARNING: no checksum available for %s, skipping verification\n' "$name" >&2
    fi
}

# delta — git diff viewer
DELTA_VER=$(gh_latest "dandavison/delta")
DELTA_ARCHIVE="delta-${DELTA_VER#v}-${ARCH}-unknown-linux-musl.tar.gz"
dl_verify "$GHREL/$DELTA_ARCHIVE" \
    "https://github.com/dandavison/delta/releases/download/${DELTA_VER}/${DELTA_ARCHIVE}" \
    "https://github.com/dandavison/delta/releases/download/${DELTA_VER}/sha256sums"
tar -xz -C "$GHREL" -f "$GHREL/$DELTA_ARCHIVE"
install -m755 "$GHREL/delta-${DELTA_VER#v}-${ARCH}-unknown-linux-musl/delta" "$INSTALL_DIR/delta"

# dust — disk usage (du alternative)
DUST_VER=$(gh_latest "bootandy/dust")
DUST_ARCHIVE="dust-${DUST_VER}-${ARCH}-unknown-linux-musl.tar.gz"
curl -fsSL -o "$GHREL/$DUST_ARCHIVE" \
    "https://github.com/bootandy/dust/releases/download/${DUST_VER}/${DUST_ARCHIVE}"
tar -xz -C "$GHREL" -f "$GHREL/$DUST_ARCHIVE"
install -m755 "$GHREL/dust-${DUST_VER}-${ARCH}-unknown-linux-musl/dust" "$INSTALL_DIR/dust"

# ouch — universal archive tool
OUCH_VER=$(gh_latest "ouch-org/ouch")
OUCH_ARCHIVE="ouch-${ARCH}-unknown-linux-musl.tar.gz"
curl -fsSL -o "$GHREL/$OUCH_ARCHIVE" \
    "https://github.com/ouch-org/ouch/releases/download/${OUCH_VER}/${OUCH_ARCHIVE}"
tar -xz -C "$GHREL" -f "$GHREL/$OUCH_ARCHIVE"
install -m755 "$GHREL/ouch-${ARCH}-unknown-linux-musl/ouch" "$INSTALL_DIR/ouch"

# sd — sed alternative
SD_VER=$(gh_latest "chmln/sd")
SD_ARCHIVE="sd-${SD_VER}-${ARCH}-unknown-linux-musl.tar.gz"
curl -fsSL -o "$GHREL/$SD_ARCHIVE" \
    "https://github.com/chmln/sd/releases/download/${SD_VER}/${SD_ARCHIVE}"
tar -xz -C "$GHREL" -f "$GHREL/$SD_ARCHIVE"
install -m755 "$GHREL/sd-${SD_VER}-${ARCH}-unknown-linux-musl/sd" "$INSTALL_DIR/sd"

# watchexec — file watcher / task runner
WATCHEXEC_VER=$(gh_latest "watchexec/watchexec")
WATCHEXEC_ARCHIVE="watchexec-${WATCHEXEC_VER#v}-${ARCH}-unknown-linux-musl.tar.xz"
curl -fsSL -o "$GHREL/$WATCHEXEC_ARCHIVE" \
    "https://github.com/watchexec/watchexec/releases/download/${WATCHEXEC_VER}/${WATCHEXEC_ARCHIVE}"
tar -xJ -C "$GHREL" -f "$GHREL/$WATCHEXEC_ARCHIVE"
install -m755 "$GHREL/watchexec-${WATCHEXEC_VER#v}-${ARCH}-unknown-linux-musl/watchexec" "$INSTALL_DIR/watchexec"

# xh — HTTP client (httpie alternative)
XH_VER=$(gh_latest "ducaale/xh")
XH_ARCHIVE="xh-${XH_VER}-${ARCH}-unknown-linux-musl.tar.gz"
curl -fsSL -o "$GHREL/$XH_ARCHIVE" \
    "https://github.com/ducaale/xh/releases/download/${XH_VER}/${XH_ARCHIVE}"
tar -xz -C "$GHREL" -f "$GHREL/$XH_ARCHIVE"
install -m755 "$GHREL/xh-${XH_VER}-${ARCH}-unknown-linux-musl/xh" "$INSTALL_DIR/xh"

# xcp — cp with progress (tag has "xcp-" prefix, gnu only)
XCP_VER=$(gh_latest "tarka/xcp")
XCP_VER_CLEAN="${XCP_VER#xcp-}"
XCP_ARCHIVE="xcp-${XCP_VER_CLEAN}-${ARCH}-unknown-linux-gnu.tar.gz"
curl -fsSL -o "$GHREL/$XCP_ARCHIVE" \
    "https://github.com/tarka/xcp/releases/download/${XCP_VER}/${XCP_ARCHIVE}"
tar -xz -C "$GHREL" -f "$GHREL/$XCP_ARCHIVE"
install -m755 "$GHREL/xcp-${XCP_VER_CLEAN}-${ARCH}-unknown-linux-gnu/bin/xcp" "$INSTALL_DIR/xcp"

# xsv — CSV toolkit
XSV_VER=$(gh_latest "BurntSushi/xsv")
XSV_ARCHIVE="xsv-${XSV_VER}-${ARCH}-unknown-linux-musl.tar.gz"
curl -fsSL -o "$GHREL/$XSV_ARCHIVE" \
    "https://github.com/BurntSushi/xsv/releases/download/${XSV_VER}/${XSV_ARCHIVE}"
tar -xz -C "$GHREL" -f "$GHREL/$XSV_ARCHIVE"
install -m755 "$GHREL/xsv" "$INSTALL_DIR/xsv"

# zellij — terminal multiplexer
ZELLIJ_VER=$(gh_latest "zellij-org/zellij")
ZELLIJ_ARCHIVE="zellij-${ARCH}-unknown-linux-musl.tar.gz"
dl_verify "$GHREL/$ZELLIJ_ARCHIVE" \
    "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VER}/${ZELLIJ_ARCHIVE}" \
    "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VER}/sha256sums"
tar -xz -C "$GHREL" -f "$GHREL/$ZELLIJ_ARCHIVE"
install -m755 "$GHREL/zellij" "$INSTALL_DIR/zellij"

# pipr — interactive shell pipeline builder
PIPR_VER=$(gh_latest "elkowar/pipr")
curl -fsSL \
    "https://github.com/elkowar/pipr/releases/download/${PIPR_VER}/pipr" \
    -o "$GHREL/pipr"
install -m755 "$GHREL/pipr" "$INSTALL_DIR/pipr"

# starship — cross-shell prompt
STARSHIP_VER=$(gh_latest "starship/starship")
STARSHIP_ARCHIVE="starship-${ARCH}-unknown-linux-musl.tar.gz"
dl_verify "$GHREL/$STARSHIP_ARCHIVE" \
    "https://github.com/starship/starship/releases/download/${STARSHIP_VER}/${STARSHIP_ARCHIVE}" \
    "https://github.com/starship/starship/releases/download/${STARSHIP_VER}/${STARSHIP_ARCHIVE}.sha256"
tar -xz -C "$GHREL" -f "$GHREL/$STARSHIP_ARCHIVE"
install -m755 "$GHREL/starship" "$INSTALL_DIR/starship"

# ripsecrets — secret scanner (gnu only)
RIPSECRETS_VER=$(gh_latest "sirwart/ripsecrets")
RIPSECRETS_VER_CLEAN="${RIPSECRETS_VER#v}"
RIPSECRETS_ARCHIVE="ripsecrets-${RIPSECRETS_VER_CLEAN}-${ARCH}-unknown-linux-gnu.tar.gz"
curl -fsSL -o "$GHREL/$RIPSECRETS_ARCHIVE" \
    "https://github.com/sirwart/ripsecrets/releases/download/${RIPSECRETS_VER}/${RIPSECRETS_ARCHIVE}"
tar -xz -C "$GHREL" -f "$GHREL/$RIPSECRETS_ARCHIVE"
install -m755 "$GHREL/ripsecrets-${RIPSECRETS_VER_CLEAN}-${ARCH}-unknown-linux-gnu/ripsecrets" "$INSTALL_DIR/ripsecrets"

# glow — markdown renderer
GLOW_VER=$(gh_latest "charmbracelet/glow")
GLOW_ARCHIVE="glow_${GLOW_VER#v}_Linux_x86_64.tar.gz"
dl_verify "$GHREL/$GLOW_ARCHIVE" \
    "https://github.com/charmbracelet/glow/releases/download/${GLOW_VER}/${GLOW_ARCHIVE}" \
    "https://github.com/charmbracelet/glow/releases/download/${GLOW_VER}/checksums.txt"
tar -xz -C "$GHREL" -f "$GHREL/$GLOW_ARCHIVE"
install -m755 "$GHREL/glow_${GLOW_VER#v}_Linux_x86_64/glow" "$INSTALL_DIR/glow"

# carapace — shell completions (asset name is carapace-bin_*)
CARAPACE_VER=$(gh_latest "carapace-sh/carapace-bin")
CARAPACE_ARCHIVE="carapace-bin_${CARAPACE_VER#v}_linux_amd64.tar.gz"
dl_verify "$GHREL/$CARAPACE_ARCHIVE" \
    "https://github.com/carapace-sh/carapace-bin/releases/download/${CARAPACE_VER}/${CARAPACE_ARCHIVE}" \
    "https://github.com/carapace-sh/carapace-bin/releases/download/${CARAPACE_VER}/checksums.txt"
tar -xz -C "$GHREL" -f "$GHREL/$CARAPACE_ARCHIVE"
install -m755 "$GHREL/carapace" "$INSTALL_DIR/carapace"

# yazi — file manager TUI (not in Fedora 43 repos)
YAZI_VER=$(gh_latest "sxyazi/yazi")
YAZI_ARCHIVE="yazi-${ARCH}-unknown-linux-musl.zip"
dl_verify "$GHREL/$YAZI_ARCHIVE" \
    "https://github.com/sxyazi/yazi/releases/download/${YAZI_VER}/${YAZI_ARCHIVE}" \
    "https://github.com/sxyazi/yazi/releases/download/${YAZI_VER}/${YAZI_ARCHIVE}.sha256"
unzip -q "$GHREL/$YAZI_ARCHIVE" -d "$GHREL"
install -m755 "$GHREL/yazi-${ARCH}-unknown-linux-musl/yazi" "$INSTALL_DIR/yazi"
install -m755 "$GHREL/yazi-${ARCH}-unknown-linux-musl/ya" "$INSTALL_DIR/ya"

# lazydocker — docker/podman TUI
LAZYDOCKER_VER=$(gh_latest "jesseduffield/lazydocker")
LAZYDOCKER_ARCHIVE="lazydocker_${LAZYDOCKER_VER#v}_Linux_x86_64.tar.gz"
dl_verify "$GHREL/$LAZYDOCKER_ARCHIVE" \
    "https://github.com/jesseduffield/lazydocker/releases/download/${LAZYDOCKER_VER}/${LAZYDOCKER_ARCHIVE}" \
    "https://github.com/jesseduffield/lazydocker/releases/download/${LAZYDOCKER_VER}/checksums.txt"
tar -xz -C "$GHREL" -f "$GHREL/$LAZYDOCKER_ARCHIVE"
install -m755 "$GHREL/lazydocker" "$INSTALL_DIR/lazydocker"

# act — run GitHub Actions locally with Docker/Podman
ACT_VER=$(gh_latest "nektos/act")
ACT_ARCHIVE="act_Linux_x86_64.tar.gz"
dl_verify "$GHREL/$ACT_ARCHIVE" \
    "https://github.com/nektos/act/releases/download/${ACT_VER}/${ACT_ARCHIVE}" \
    "https://github.com/nektos/act/releases/download/${ACT_VER}/checksums.txt"
tar -xz -C "$GHREL" -f "$GHREL/$ACT_ARCHIVE"
install -m755 "$GHREL/act" "$INSTALL_DIR/act"

# TODO: gitoxide (Byron/gitoxide) — asset naming changes between releases.
# Verify the correct asset name at https://github.com/Byron/gitoxide/releases/latest
# before adding back. Previously "gitoxide-max-termsize-*-x86_64-unknown-linux-musl.tar.gz"
# but this variant was not present in v0.52.0.

### Gaming environment optimizations
# Shader Booster — increase GPU shader cache (github.com/psygreg/shader-booster)
echo "__GL_SHADER_DISK_CACHE_SIZE=10000000000" >> /etc/environment  # NVIDIA (535+)
echo "AMD_VULKAN_ICD=RADV" >> /etc/environment                       # force RADV Vulkan (Mesa)
echo "MESA_SHADER_CACHE_MAX_SIZE=10G" >> /etc/environment            # Mesa shader cache (23.1+)
# Threaded OpenGL optimizations
echo "__GL_THREADED_OPTIMIZATIONS=1" >> /etc/environment             # NVIDIA threaded GL
echo "mesa_glthread=true" >> /etc/environment                        # Mesa threaded GL
# Wine/Proton FSR upscaling (fullscreen, all games)
echo "WINE_FULLSCREEN_FSR=1" >> /etc/environment
echo "WINE_FSR_STRENGTH=2" >> /etc/environment
# DXVK async shader compilation (reduces stutter; minor visual artifacts possible)
echo "DXVK_ASYNC=1" >> /etc/environment

### Services
systemctl enable podman.socket
systemctl enable docker.service
systemctl enable tailscaled

### Ensure zshrc.d directory exists
mkdir -p /etc/zshrc.d

### Patch os-release identity (drop-ins are not read by fastfetch/most tools directly)
sed -i \
    -e 's|^NAME=.*|NAME="Luka OS"|' \
    -e 's|^PRETTY_NAME=.*|PRETTY_NAME="Luka OS (Bazzite)"|' \
    -e 's|^ID=.*|ID=luka-os|' \
    -e 's|^ID_LIKE=.*|ID_LIKE="bazzite fedora"|' \
    -e 's|^HOME_URL=.*|HOME_URL="https://github.com/LLawli/luka_os"|' \
    -e 's|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL="https://github.com/LLawli/luka_os"|' \
    /usr/lib/os-release

### Remove default alias scripts that conflict with custom aliases
rm -f /etc/profile.d/colorls.sh /etc/profile.d/colorgrep.sh
rm -f /etc/profile.d/colorls.csh /etc/profile.d/colorgrep.csh

### Cleanup
dnf5 clean all

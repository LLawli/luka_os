#!/bin/bash

set -ouex pipefail

### Extra repos
dnf5 -y copr enable alternateved/eza
dnf5 -y copr enable dejan/lazygit

### Install packages
dnf5 install -y \
    tmux git gh neovim \
    fzf ripgrep fd-find bat jq yq tree unzip wget curl rsync lsof strace shellcheck direnv \
    gcc-c++ clang make cmake ninja-build pkgconf-pkg-config openssl-devel sqlite-devel zlib-devel libffi-devel \
    podman podman-docker podman-compose buildah skopeo \
    zoxide age tree-sitter delta btop eza lazygit \
    p7zip p7zip-plugins unrar \
    mtr nmap netcat tcpdump \
    htop iotop ncdu tldr entr progress hyperfine ltrace perf httpie tailscale bind-utils sqlite openssl

### Disable extra repos after install
dnf5 -y copr disable alternateved/eza
dnf5 -y copr disable dejan/lazygit

### Services
systemctl enable podman.socket
systemctl enable tailscaled
### Remove default alias scripts that conflict with custom aliases
rm -f /etc/profile.d/colorls.sh /etc/profile.d/colorgrep.sh
rm -f /etc/profile.d/colorls.csh /etc/profile.d/colorgrep.csh

### Cleanup
dnf5 clean all

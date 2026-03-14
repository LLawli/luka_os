#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux git gh neovim fzf ripgrep fd-find bat jq yq tree unzip wget curl rsync lsof strace shellcheck direnv gcc-c++ clang make cmake ninja-build pkgconf-pkg-config openssl-devel sqlite-devel zlib-devel libffi-devel podman podman-docker podman-compose buildah skopeo zoxide age tree-sitter delta btop
dnf5 clean all
dnf5 -y copr enable varlad/eza
dnf5 install -y eza
dnf5 -y copr disable varlad/eza
dnf5 -y copr enable atim/lazygit
dnf5 install -y lazygit
dnf5 -y copr disable atim/lazygit
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

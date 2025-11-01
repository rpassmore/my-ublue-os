#!/bin/bash

set -ouex pipefail

# Copy System Files to Container
rsync -rvK /ctx/system_files/ /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1


dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable che/nerd-fonts
dnf5 -y copr enable atim/starship

# Setup repos for packages from Bluefin DX that we want
dnf5 -y copr enable ganto/umoci
dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable karmab/kcli
dnf5 -y copr enable atim/ubuntu-fonts
dnf5 -y copr enable hikariknight/looking-glass-kvmfr
dnf5 -y copr enable gmaglione/podman-bootc

# this installs a package from fedora repos
dnf5 -y install \
    bash-color-prompt \
    bootc \
    fastfetch \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-caffeine \
    gnome-shell-extension-search-light \
    gnome-shell-extension-blur-my-shell \
    gnome-backgrounds-extras \
    gnome-tweaks \
    starship \
    hplip \
    lm_sensors \
    oddjob-mkhomedir \
    openssh-askpass \
    powertop \
    uupd \
    nerd-fonts \
    google-noto-fonts-all \
    restic \
    switcheroo-control \
    waypipe \
    wireguard-tools \
    zsh

# Add packages from that are included in the bluefin dx version
dnf5 -y install \
    code \
    genisoimage \
    git-credential-libsecret \
    git \
    google-droid-sans-mono-fonts \
    google-go-mono-fonts \
    ibm-plex-mono-fonts \
    iotop \
    p7zip \
    p7zip-plugins \
    powerline-fonts \
    sysprof \
    tiptop \
    ubuntu-family-fonts

# Install tooling needed to develop bootc containers locally
dnf5 -y install \
    osbuild-selinux \
    podman-bootc \
    podman-compose \
    podmansh \
    gvisor-tap-vsock
    #podman-machine

    #docker-buildx-plugin \
    #docker-ce \
    #docker-ce-cli \
    #docker-compose-plugin \
    #docker-model-plugin \
    #rocm-hip \
    #rocm-opencl \
    #rocm-smi \

# Remove packages
dnf5 remove -y \
    firefox \
    firefox-langpacks \
    gnome-software \
    gnome-extensions-app \
    gnome-shell-extension-background-logo \
    gnome-software-rpm-ostree \
    gnome-terminal-nautilus \
    yubikey-manager

# Install macadam it is needed by the podman-desktop-bootc extension, but is not packaged by fedora yet.
mkdir -p /usr/local/bin
curl -L -o /usr/local/bin/macadam https://github.com/crc-org/macadam/releases/download/v0.2.0/macadam-linux-amd64
chmod +x /usr/local/bin/macadam

# Install dynamic wallpapers
curl -s "https://raw.githubusercontent.com/rpassmore/Linux_Dynamic_Wallpapers/main/Easy_Install.sh" | bash

# Swap flatpak repos, this is done in a systemd unit for now
# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# flatpak remote-modify --no-filter --enable flathub

#### Example for enabling a System Unit File
systemctl enable podman.socket
# systemctl enable dconf-update.service
systemctl enable flatpak-add-flathub-repo.service
systemctl enable flatpak-replace-fedora-apps.service
systemctl enable flatpak-cleanup.timer

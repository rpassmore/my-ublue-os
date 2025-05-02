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

# install new kernel & remove old one
dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra
dnf5 -y install kernel-cachyos kernel-cachyos-devel-matched
dnf5 -y copr disable bieszczaders/kernel-cachyos        

# this installs a package from fedora repos
dnf5 -y install \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-caffeine \
    starship \
    zsh \
    gnome-backgrounds-extras \
    gnome-tweaks \
    bash-color-prompt \
    bootc \
    borgbackup \
    hplip \
    lm_sensors \
    oddjob-mkhomedir \
    openssh-askpass \
    powertop \
    uupd 

# Remove packages
dnf5 remove -y firefox
dnf5 remove -y firefox-langpacks # also remove firefox dependency (not required for all packages, this is a special case)
dnf5 remove -y gnome-shell-extension-background-logo
dnf5 remove -y nvtop
dnf5 remove -y wireguard-tools
dnf5 remove -y yubikey-manager

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable ublue-os/packages
dnf5 -y copr disable che/nerd-fonts
dnf5 -y copr enable atim/starship

# Swap flatpak repos
# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# flatpak remote-modify --no-filter --enable flathub

#### Example for enabling a System Unit File
systemctl enable podman.socket
# systemctl enable dconf-update.service
systemctl enable flatpak-add-flathub-repo.service
systemctl enable flatpak-replace-fedora-apps.service
systemctl enable flatpak-cleanup.timer
# systemctl enable rpm-ostreed-automatic.timer

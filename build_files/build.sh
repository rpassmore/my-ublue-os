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
dnf5 -y install --nogpgcheck --repofrompath 'terra-rp,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras}
dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="nerd-fonts topgrade"
dnf5 -y config-manager setopt "terra-mesa".enabled=true
dnf5 -y config-manager setopt "terra-nvidia".enabled=false
    
# this installs a package from fedora repos
dnf5 -y install \
    code \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-caffeine \
    starship \
    zsh \
    gnome-backgrounds-extras \
    gnome-tweaks \
    bash-color-prompt \
    bootc \
    hplip \
    restic \
    lm_sensors \
    oddjob-mkhomedir \
    openssh-askpass \
    powertop \
    uupd \
    nerd-fonts \
    bazaar \
    google-noto-fonts-all

# Remove base packages
dnf5 remove -y \
    firefox \
    firefox-langpacks \
    gnome-shell-extension-background-logo \
    yubikey-manager \
    gnome-software

########################################################
# Add & remove package from bluefin
# Setup repos for packages from Bluefin DX that we want
#umoci
dnf5 -y copr enable ganto/umoci
#ublue-os staging
dnf5 -y copr enable ublue-os/staging
#ublue-os packages
dnf5 -y copr enable ublue-os/packages
#karmab-kcli
dnf5 -y copr enable karmab/kcli
# Fonts
dnf5 -y copr enable atim/ubuntu-fonts
# Kvmfr module
dnf5 -y copr enable hikariknight/looking-glass-kvmfr
# Podman-bootc
dnf5 -y copr enable gmaglione/podman-bootc

# Remove packages from Bluefin
dnf5 remove -y \
    borgbackup \
    fish \
    bluefin-backgrounds \
    bluefin-cli-logos \
    bluefin-plymouth \
    bluefin-schemas \
    bluefin-fastfetch \
    gnome-shell-extension-tailscale-gnome-qs \
    gnome-shell-extension-gsconnect \
    nautilus-gsconnect \
    tailscale

dnf5 -y install \
    code \
    genisoimage \
    google-droid-sans-mono-fonts \
    google-go-mono-fonts \
    ibm-plex-mono-fonts \
    iotop \
    p7zip \
    p7zip-plugins \
    podmansh \
    powerline-fonts \
    sysprof \
    tiptop \
    ubuntu-family-fonts \
    plymouth-system-theme
    #docker-buildx-plugin \
    #docker-ce \
    #docker-ce-cli \
    #docker-compose-plugin \
    #docker-model-plugin \
#podman-bootc \
#podman-compose \
#podman-machine \
#    rocm-hip \
#     rocm-opencl \
#     rocm-smi \
# Install Oh My Posh (there is no pagage for this yet)
#curl -s https://ohmyposh.dev/install.sh | bash -s 

dnf5 -y swap bluefin-logos fedora-logos
dnf5 -y swap bluefin-logos system-logos

# Swap flatpak repos, this is done in a systemd unit for now
# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# flatpak remote-modify --no-filter --enable flathub

#### Example for enabling a System Unit File
systemctl enable podman.socket
# systemctl enable dconf-update.service
systemctl enable flatpak-add-flathub-repo.service
systemctl enable flatpak-replace-fedora-apps.service
systemctl enable flatpak-cleanup.timer

#!/usr/bin/bash

set -eoux pipefail

dnf5 -y copr disable ublue-os/packages
dnf5 -y copr disable che/nerd-fonts
dnf5 -y copr disable atim/starship
dnf5 -y config-manager setopt terra.enabled=0

# DX repos
#umoci
dnf5 -y copr disable ganto/umoci
#ublue-os staging
dnf5 -y copr disable ublue-os/staging
#ublue-os packages
dnf5 -y copr disable ublue-os/packages
#karmab-kcli
dnf5 -y copr disable karmab/kcli
# Fonts
dnf5 -y copr disable atim/ubuntu-fonts
# Kvmfr module
dnf5 -y copr disable hikariknight/looking-glass-kvmfr
# Podman-bootc
dnf5 -y copr disable gmaglione/podman-bootc

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/vscode.repo

dnf5 clean all

# Cleanup some tmp files and cache folders
rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;

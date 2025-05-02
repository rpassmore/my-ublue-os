
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-bazzite}"
ARG FEDORA_VERSION=42
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.14.4-103.bazzite.fc42.x86_64}"


# FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods
# FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-extra

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY / /

# Base Image6.12.5-204.bazzite.fc41.x86_64}
FROM ghcr.io/ublue-os/silverblue-main:42

# ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-bazzite}"
# ARG FEDORA_VERSION=42
# ARG KERNEL_VERSION="${KERNEL_VERSION:-6.14.4-103.bazzite.fc42.x86_64}"

# Setup Copr repos
# RUN --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=tmpfs,dst=/tmp \
#     mkdir -p /var/roothome && \
#     dnf5 -y install \
#         https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
#         https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
#     sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
#     dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo && \
#     dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-rar.repo && \
#     dnf5 -y config-manager setopt "*akmods*".priority=2 && \
#     dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*" && \
#     dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*" && \
#     /ctx/build_files/cleanup.sh

# Install kernel
# RUN --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
#     --mount=type=bind,from=akmods,src=/rpms,dst=/tmp/akmods-rpms \
#     --mount=type=bind,from=akmods-extra,src=/rpms,dst=/tmp/akmods-extra-rpms \
#     --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/install-kernel-akmods.sh && \
#     dnf5 -y config-manager setopt "*rpmfusion*".enabled=0 && \
#     dnf5 -y copr enable bieszczaders/kernel-cachyos-addons && \
#     dnf5 -y install \
#         scx-scheds && \
#     dnf5 -y copr disable bieszczaders/kernel-cachyos-addons && \
#     dnf5 -y swap --repo copr:copr.fedorainfracloud.org:bazzite-org:bazzite bootc bootc 
#     # /ctx/build_files/cleanup.sh

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/build.sh && \
    ostree container commit
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
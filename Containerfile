ARG BASE_IMAGE=ghcr.io/ublue-os/silverblue-main:44@sha256:d5179f94887b40b1c177dfb4be6a61832c3d470fce5a7ce7f5bf7b228ba32243

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY / /

FROM ${BASE_IMAGE}

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

# Copy Homebrew files from the brew image
COPY --from=ghcr.io/projectbluefin/brew:latest /system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/build.sh && \
    /ctx/build_files/cleanup.sh && \
    ostree container commit
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

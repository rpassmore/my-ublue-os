ARG BASE_IMAGE=ghcr.io/ublue-os/silverblue-main:42@sha256:ff8791a8fbd51bf802f077df61a4bbe2919710e519e5711b1d7bb003d893508d

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY / /

FROM ${BASE_IMAGE}

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

# Copy Homebrew files from the brew image
COPY --from=ghcr.io/projectbluefin/brew:latest@sha256:1f7cda525c33703841f0a392f89fc803d96e68ecd331ec09c7dda2d1d1b3ceff /system_files /

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

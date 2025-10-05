ARG BASE_IMAGE=ghcr.io/ublue-os/silverblue-main:42@sha256:cfa0856808bf4e097a980feb0781f5aa7827229ef67e83250c7fe2269e16b950

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

COPY / /

FROM ${BASE_IMAGE}

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

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

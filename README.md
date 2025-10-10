# my-ublue-os

A customised Universal Blue (uBlue) bootc image for Fedora Atomic systems, with batteries-included defaults and tooling to build, sign, and distribute both OCI images and bootable ISOs.

This repository started from the official uBlue image-template and has been tailored with my preferred packages, systemd services, and workflows. It is suitable as a starting point for your own image too.

- Base technology: bootc + Fedora Atomic/Silverblue
- Build targets: OCI image (GHCR) and bootable ISO
- Tooling: Justfile, Podman, bootc-image-builder, GitHub Actions, cosign signing

Contents
- What you get
- Quick start
- Customize the image
- Build locally
- Build ISOs
- GitHub Actions and secrets
- Signing and verification (cosign)
- Repo layout
- Troubleshooting
- Community and examples
- License

What you get
- Preconfigured package set for a developer-friendly desktop
  - Notable additions: starship, fastfetch, podman-bootc, VS Code, fonts (nerd-fonts, Ubuntu, IBM Plex Mono, Droid Mono), utilities (sysprof, iotop, tiptop, p7zip), WireGuard tools
  - Removals: Firefox, GNOME Software and related extras, YubiKey Manager, etc.
- System services enabled out of the box
  - podman.socket
  - Flatpak helpers: add Flathub, replace Fedora apps, periodic cleanup
- Ready-to-use build recipes
  - Containerfile for the image
  - Justfile tasks to build/run VM images and ISOs
  - disk_config/ for ISO configuration
  - GitHub Actions workflows for image and ISO builds

Quick start
1) Fork or use this repo as a template
- Update names in Justfile variables if desired (repo_organization, image_name, default_tag).
- Optionally change image metadata in Containerfile and image.toml.

2) Build the OCI image locally (Podman)
- podman build -t ghcr.io/<your-gh-username>/<image-name>:<tag> -f Containerfile .
- Example tag scheme: latest or lts.

3) Boot onto the image with bootc (advanced)
- See bootc docs: https://bootc-dev.github.io/bootc/

4) Enable GitHub Actions
- Push your repo to GitHub.
- In GitHub → Actions, enable workflows. The image will publish to GHCR by default.

Customize the image
- Containerfile: Base image and layering
  - Switch base to any uBlue image (Aurora, Bluefin, Bazzite, uCore) or to Fedora/CentOS bootc images.
- build_files/build.sh: Package selection and services
  - Installs packages from Fedora and COPR repos and enables systemd units. This is the primary place to add/remove packages.
  - Notable COPR repos already enabled: ublue-os/packages, atim/starship, che/nerd-fonts, karmab/kcli, gmaglione/podman-bootc, etc.
- system_files/: Files copied into the image at build time
  - Systemd units for Flatpak management
  - Repository definitions (e.g., docker-ce.repo, vscode.repo)
- image.toml: Image metadata for bootc
- disk_config/: bootc-image-builder config for ISOs

Build locally
- Requirements
  - Podman (or Docker with compatible flags), just (optional but recommended), and sufficient disk space.
- Useful Justfile commands
  - just build <target_image> <tag> [dx] [hwe] [gdx]
    - Builds the OCI image. target_image defaults to aurora; tag defaults to lts; feature flags are optional.
  - VM/ISO images
    - just build-qcow2 <target_image> <tag>
    - just build-raw <target_image> <tag>
    - just build-iso <target_image> <tag>
    - just run-vm-qcow2 <target_image> <tag>
    - just run-vm-raw <target_image> <tag>
    - just run-vm-iso <target_image> <tag>
    - just spawn-vm rebuild="0" type="qcow2" ram="6G"
  - Maintenance
    - just clean, just lint, just format, just check, just fix

Build ISOs
- Configure image reference in disk_config/iso.toml
  - Set the image to your GHCR reference (e.g., ghcr.io/<org>/<image>:<tag>).
- Build locally via Justfile
  - just build-iso <target_image> <tag>
- Or via GitHub Actions (build-iso.yml)
  - Add S3 credentials if you want artifacts uploaded to your bucket via rclone.
    - Required secrets: S3_PROVIDER, S3_BUCKET_NAME, S3_ACCESS_KEY_ID, S3_SECRET_ACCESS_KEY, S3_REGION (or auto), S3_ENDPOINT.
  - Otherwise, download the ISO from the workflow run artifacts.

GitHub Actions and secrets
- Image build and publish (build.yml)
  - Publishes to ghcr.io/<owner>/<repo> using the repo name by default.
- ISO build (build-iso.yml)
  - Uses bootc-image-builder to create an ISO from your published OCI image.
- Required secrets (recommended)
  - SIGNING_SECRET: Contents of cosign.key (see Signing and verification)
  - Optional: S3_* variables if uploading ISOs

Signing and verification (cosign)
- Install cosign: https://edu.chainguard.dev/open-source/sigstore/cosign/how-to-install-cosign/
- Generate keys (no passphrase for GitHub Actions):
  - cosign generate-key-pair
- Add private key to GitHub as Actions secret SIGNING_SECRET
  - gh secret set SIGNING_SECRET < cosign.key
- Commit only cosign.pub to the repository root
  - Important: Do NOT commit cosign.key. If it has been committed in your fork, rotate and remove it immediately (git history rewrite may be required).
- Verify signatures
  - cosign verify ghcr.io/<org>/<image>:<tag> \
      --key cosign.pub

Repo layout
- Containerfile: Image build recipe
- Justfile: High-level build tasks and helpers
- build_files/build.sh: Package install/remove and service enablement
- build_files/cleanup.sh: Finalization/cleanup script
- system_files/: Files copied into the image (systemd units, repos, config)
  - systemd units:
    - usr/lib/systemd/system/flatpak-add-flathub-repo.service
    - usr/lib/systemd/system/flatpak-replace-fedora-apps.service
    - usr/lib/systemd/system/flatpak-cleanup.service
    - usr/lib/systemd/system/flatpak-cleanup.timer
  - dracut config: usr/lib/dracut/dracut.conf.d/10-compression.conf
  - repo files: etc/yum.repos.d/*.repo (docker-ce, vscode)
  - distrobox config: etc/distrobox/distrobox.ini
- disk_config/
  - iso.toml and disk.toml for bootc-image-builder
- image.toml: Image metadata
- artifacthub-repo.yml: Artifact Hub publisher metadata
- LICENSE: Project license

Troubleshooting
- ISO build fails with missing image
  - Ensure your OCI image is published to GHCR and iso.toml references the correct tag.
- cosign fails or build.yml fails signing step
  - Make sure SIGNING_SECRET is set and corresponds to the cosign.pub in the repo.
- Podman errors during build
  - Run just clean and try again. Ensure network access to COPR and Fedora repos.

Community and examples
- bootc discussions: https://github.com/bootc-dev/bootc/discussions
- Artifact Hub guide: https://universal-blue.discourse.group/t/listing-your-custom-image-on-artifacthub/6446
- Example projects
  - m2os: https://github.com/m2giles/m2os
  - bos: https://github.com/bsherman/bos
  - homer: https://github.com/bketelsen/homer/


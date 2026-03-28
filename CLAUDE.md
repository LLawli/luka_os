# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A **bootc image template** that builds a custom containerized Linux OS image on top of [Universal Blue](https://universal-blue.org/) images (currently Bazzite). The container image is built with CI, signed with Cosign, and published to GHCR. It can then be applied to a running system via `bootc switch`.

## Common Commands

This project uses `just` as the task runner. Install it with `sudo dnf install just`.

```bash
# Build the container image locally
just build

# Lint shell scripts with shellcheck
just lint

# Format shell scripts with shfmt
just format

# Check/fix Justfile syntax
just check
just fix

# Build a qcow2 VM image and run it in QEMU
just build-qcow2
just run-vm-qcow2

# Clean all build artifacts
just clean
```

## Architecture

```
Containerfile          # OCI image definition — base image selection + build stages
build_files/build.sh   # Runs inside the container during build (dnf installs, service enables)
system_files/          # Copied verbatim into the final image filesystem
  etc/profile.d/       # Shell environment: starship, zoxide, env vars, aliases
  usr/local/bin/       # Custom helper scripts (e.g. dx-groups for GPU group setup)
disk_config/           # Bootc Image Builder configs for VM/ISO output
.github/workflows/
  build.yml            # Main CI: builds, pushes to GHCR, signs with Cosign
  build-disk.yml       # Manual: builds qcow2/ISO disk images, optionally uploads to S3
```

### Build Flow

1. `Containerfile` uses a two-stage build: `scratch AS ctx` mounts `build_files/` without embedding them in the final layer.
2. `build.sh` runs with dnf5 to install packages (enables COPR repos during install, disables after), enables systemd services, and removes conflicting default scripts.
3. `system_files/` contents are `COPY`-ed into `/etc` and `/usr/local`.
4. `bootc container lint` validates the image at the end of the build.

### CI

- Builds are triggered on push to `main`, PRs, daily schedule, and `workflow_dispatch`.
- Images are pushed to GHCR only from the `main` branch (not PRs).
- Tags: `latest`, `latest.YYYYMMDD`, `YYYYMMDD`, and PR SHA on PRs.
- Cosign signs images using the `SIGNING_SECRET` repository secret and the `cosign.pub` public key.

## Key Variables

In `Justfile`:
- `IMAGE_NAME` — default `"lukakuuhaku"`
- `DEFAULT_TAG` — default `"latest"`
- `BIB_IMAGE` — Bootc Image Builder container image

In `.github/workflows/build.yml`:
- `IMAGE_NAME` env var controls the GHCR image name.

## Customization Points

- **Base image**: Change the `FROM` line in `Containerfile`
- **Packages**: Edit the `dnf install` call in `build_files/build.sh`
- **Shell environment**: Edit files under `system_files/etc/profile.d/`
- **Disk/ISO installer behavior**: Edit `disk_config/*.toml`

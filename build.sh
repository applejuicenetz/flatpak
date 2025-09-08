#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://applejuicenetz.github.io/flatpak/repo/applejuice.flatpakrepo"
TARGET="${1:-}"
ARCH_UNAME="${ARCH:-$(uname -m)}"

# Map uname to flatpak arch
case "$ARCH_UNAME" in
  aarch64) ARCH="aarch64" ;;
  x86_64)  ARCH="x86_64" ;;
  armv7l|armv7hf|armhf) ARCH="arm" ;;
  *) echo "Unsupported arch: $ARCH_UNAME" >&2; exit 1 ;;
 esac

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 {core|collector|gui} [--include-deps]" >&2
  exit 1
fi

# Per-target config
case "$TARGET" in
  core)
    APP_ID="org.applejuicenetz.core"
    VERSION="0.31.149.113"
    ;;
  collector)
    APP_ID="org.applejuicenetz.collector"
    VERSION="3.1.0"
    ;;
  gui)
    APP_ID="org.applejuicenetz.gui"
    VERSION="0.85.1"
    ;;
  *)
    echo "Unknown target: $TARGET" >&2
    exit 1
    ;;
 esac

echo "Building: ${APP_ID} @ ${VERSION} (${ARCH})"

flatpak-builder --arch="${ARCH}" --default-branch="${VERSION}" --repo=repo --force-clean build/${TARGET} "flatpak/${APP_ID}.yaml"

flatpak build-update-repo repo --title="appleJuice P2P" --generate-static-deltas

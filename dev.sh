#!/usr/bin/env bash

# UTM start debian 12
# ssh debian@flatpack
# cd /media/share/appleJuiceNET/flatpak/
# ./dev.sh core

TARGET=$1

if [ -z "${TARGET}" ]; then
  echo "Usage: $0 {core|collector|gui}"
  exit 1
fi

mkdir -p build/

flatpak remove org.freedesktop.Sdk.Extension.openjdk21 --user -y --noninteractive  > /dev/null 2>&1

flatpak-builder --user --force-clean --install "build/${TARGET}" --force-clean "flatpak/org.applejuicenetz.${TARGET}.yaml"

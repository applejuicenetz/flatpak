FROM docker.io/debian:bookworm-slim

RUN apt update -qq && \
    apt install -qq -y --no-install-recommends \
    ca-certificates \
    flatpak \
    gnupg \
    dirmngr \
    unzip \
    make \
    pinentry-curses \
    flatpak-builder \
    qemu-user-static \
    binfmt-support \
    appstream \
    appstream-util && \
    rm -rf /usr/share/doc/* /usr/share/man/*

RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

RUN flatpak install -y --arch=aarch64  \
    flathub org.freedesktop.Sdk//23.08 \
    org.freedesktop.Platform//23.08 \
    org.freedesktop.Sdk.Extension.openjdk21//23.08

RUN flatpak install -y --arch=x86_64  \
    flathub org.freedesktop.Sdk//23.08 \
    org.freedesktop.Platform//23.08 \
    org.freedesktop.Sdk.Extension.openjdk21//23.08

# GPG non-interactive defaults for CI
ENV GPG_TTY=/dev/tty

VOLUME /workdir

WORKDIR /workdir

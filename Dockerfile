FROM docker.io/debian:trixie-slim

RUN apt update -qq && \
    apt install -qq -y --no-install-recommends \
    ca-certificates \
    flatpak \
    gnupg \
    dirmngr \
    make \
    gh \
    jq \
    ostree && \
    rm -rf /usr/share/doc/* /usr/share/man/*

VOLUME /workdir

WORKDIR /workdir

ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.DEFAULT_GOAL := build-all

# Default args for flatpak-builder in CI (override via environment or make VAR=...).
FLATPAK_BUILDER_ARGS ?= --repo="./repo/" --force-clean

gpg-key-import:
	gpg --import "${GPG_KEY_FILE}"

gpg-public-export:
	gpg --armor --export "${GPG_KEY}" > ./repo/applejuice.gpg

repo-init:
	ostree init --repo="./repo/" --mode=archive-z2

repo-list:
	ostree refs --repo="./repo/"

repo-sign:
	flatpak build-sign --gpg-sign="${GPG_KEY}" "./repo/"
	flatpak build-update-repo --gpg-sign="${GPG_KEY}" --default-branch="stable" --prune "./repo/"

build-clean:
	rm -rf .flatpak-builder/*
	rm -rf build/*

repo-rebuild:
	ostree refs --repo="./repo/" --delete app || true
	ostree refs --repo="./repo/" --delete appstream || true
	ostree refs --repo="./repo/" --delete appstream2 || true
	ostree prune --repo="./repo/"
	flatpak build-update-repo --prune --prune-depth=0 --generate-static-deltas "./repo/"
	find "./repo/" -type d -empty -delete
	ostree init --repo="./repo/" --mode=archive-z2

rebuild-all:
	@$(MAKE) build-clean
	@$(MAKE) repo-rebuild
	@$(MAKE) build-all

build-stable-core-local:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --user --default-branch="stable" --install "./build/core/stable/$(uname -m)" "./flatpak/io.github.applejuicenetz.core.yaml"

build-beta-core-local:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --user --default-branch="beta" --install "./build/core/beta/$(uname -m)" "./flatpak/io.github.applejuicenetz.core.beta.yaml"

build-stable-javagui-local:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --user --default-branch="stable" --install "./build/javagui/$(uname -m)" "./flatpak/io.github.applejuicenetz.javagui.yaml"

build-stable-collector-local:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --user --default-branch="stable" --install "./build/collector/$(uname -m)" "./flatpak/io.github.applejuicenetz.collector.yaml"

build-local-all:
	@$(MAKE) build-stable-core-local
	@$(MAKE) build-beta-core-local
	@$(MAKE) build-stable-javagui-local
	@$(MAKE) build-stable-collector-local

build-stable-core-x86_64:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --arch="x86_64" --default-branch="stable" "./build/core/stable/x86_64/" "./flatpak/io.github.applejuicenetz.core.yaml"

build-stable-core-aarch64:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --arch="aarch64" --default-branch="stable" "./build/core/stable/aarch64/" "./flatpak/io.github.applejuicenetz.core.yaml"

build-stable-javagui-x86_64:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --arch="x86_64" --default-branch="stable" "./build/javagui/x86_64/" "./flatpak/io.github.applejuicenetz.javagui.yaml"

build-stable-javagui-aarch64:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --arch="aarch64" --default-branch="stable" "./build/javagui/aarch64/" "./flatpak/io.github.applejuicenetz.javagui.yaml"

build-stable-collector-x86_64:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --arch="x86_64" --default-branch="stable" "./build/collector/x86_64/" "./flatpak/io.github.applejuicenetz.collector.yaml"

build-stable-collector-aarch64:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --arch="aarch64" --default-branch="stable" "./build/collector/aarch64/" "./flatpak/io.github.applejuicenetz.collector.yaml"

build-beta-core-x86_64:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --arch="x86_64" --default-branch="beta" "./build/core/beta/x86_64/" "./flatpak/io.github.applejuicenetz.core.beta.yaml"

build-beta-core-aarch64:
	flatpak-builder $(FLATPAK_BUILDER_ARGS) --arch="aarch64" --default-branch="beta" "./build/core/beta/aarch64/" "./flatpak/io.github.applejuicenetz.core.beta.yaml"

build-all:
	@$(MAKE) repo-init
	@$(MAKE) gpg-key-import
	@$(MAKE) build-stable-core-x86_64
	@$(MAKE) build-stable-core-aarch64
	@$(MAKE) build-beta-core-x86_64
	@$(MAKE) build-beta-core-aarch64
	@$(MAKE) build-stable-javagui-x86_64
	@$(MAKE) build-stable-javagui-aarch64
	@$(MAKE) build-stable-collector-x86_64
	@$(MAKE) build-stable-collector-aarch64
	@$(MAKE) repo-sign
	@$(MAKE) repo-list

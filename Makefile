ifneq (,$(wildcard ./.env))
    include .env
    export
endif

gpg-key-import:
	gpg --import "${GPG_KEY_FILE}"

gpg-public-export:
	gpg --armor --export "${GPG_KEY}" > ./repo/applejuice.gpg

repo-list:
	ostree refs --repo="./repo/"

repo-clean:
	flatpak build-update-repo "./repo/" --prune --prune-depth=1 --generate-static-deltas

repo-rebuild:
	ostree refs --repo="./repo/" --delete app || true
	ostree refs --repo="./repo/" --delete appstream || true
	ostree refs --repo="./repo/" --delete appstream2 || true
	ostree refs --repo="./repo/" --delete runtime || true
	ostree prune --repo="./repo/"
	flatpak build-update-repo "./repo/" --prune --prune-depth=0 --generate-static-deltas
	find "./repo/" -type d -empty -delete
	ostree init --repo="./repo/" --mode=archive-z2

repo-sign:
	flatpak build-sign ./repo/ --gpg-sign="${GPG_KEY}"
	flatpak build-update-repo "./repo/" --gpg-sign="${GPG_KEY}" --generate-static-deltas

build-clean:
	rm -rf .flatpak-builder/*
	rm -rf build/*

rebuild-all:
	@$(MAKE) build-clean
	@$(MAKE) repo-rebuild
	@$(MAKE) build-stable-all

build-local-core:
	flatpak-builder --user --default-branch="${VERSION_CORE}" --install --force-clean "./build/core/$(uname -m)" "./flatpak/io.github.applejuicenetz.core.yaml"

build-local-javagui:
	flatpak-builder --user --default-branch="${VERSION_GUI}" --install --force-clean "./build/javagui/$(uname -m)" "./flatpak/io.github.applejuicenetz.javagui.yaml"

build-local-collector:
	flatpak-builder --user --default-branch="${VERSION_COLLECTOR}" --install --force-clean "./build/collector/$(uname -m)" "./flatpak/io.github.applejuicenetz.collector.yaml"

build-local-all:
	@$(MAKE) build-local-core
	@$(MAKE) build-local-javagui
	@$(MAKE) build-local-collector

build-stable-core-x86_64:
	flatpak-builder --arch="x86_64" --default-branch="${VERSION_CORE}" --repo="./repo/" --force-clean "./build/core/x86_64/" "./flatpak/io.github.applejuicenetz.core.yaml"

build-stable-core-aarch64:
	flatpak-builder --arch="aarch64" --default-branch="${VERSION_CORE}" --repo="./repo/" --force-clean "./build/core/aarch64/" "./flatpak/io.github.applejuicenetz.core.yaml"

build-stable-javagui-x86_64:
	flatpak-builder --arch="x86_64" --default-branch="${VERSION_GUI}" --repo="./repo/" --force-clean "./build/javagui/x86_64/" "./flatpak/io.github.applejuicenetz.javagui.yaml"

build-stable-javagui-aarch64:
	flatpak-builder --arch="aarch64" --default-branch="${VERSION_GUI}" --repo="./repo/" --force-clean "./build/javagui/aarch64/" "./flatpak/io.github.applejuicenetz.javagui.yaml"

build-stable-collector-x86_64:
	flatpak-builder --arch="x86_64" --default-branch="${VERSION_COLLECTOR}" --repo="./repo/" --force-clean "./build/collector/x86_64/" "./flatpak/io.github.applejuicenetz.collector.yaml"

build-stable-collector-aarch64:
	flatpak-builder --arch="aarch64" --default-branch="${VERSION_COLLECTOR}" --repo="./repo/" --force-clean "./build/collector/aarch64/" "./flatpak/io.github.applejuicenetz.collector.yaml"

build-stable-all:
	@$(MAKE) build-stable-core-x86_64
	@$(MAKE) build-stable-core-aarch64
	@$(MAKE) build-stable-javagui-x86_64
	@$(MAKE) build-stable-javagui-aarch64
	@$(MAKE) build-stable-collector-x86_64
	@$(MAKE) build-stable-collector-aarch64
	@$(MAKE) repo-sign
	@$(MAKE) repo-list

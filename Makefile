ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.DEFAULT_GOAL := sync-all

.PHONY: gpg-key-import gpg-public-export repo-init repo-list repo-sign import-bundles sync-all

gpg-key-import:
	gpg --batch --import "${GPG_KEY_FILE}"

gpg-public-export:
	gpg --armor --export "${GPG_KEY}" > ./repo/applejuice.gpg

repo-init:
	ostree init --repo="./repo/" --mode=archive-z2

repo-list:
	ostree refs --repo="./repo/"

repo-sign:
	flatpak build-sign --gpg-sign="${GPG_KEY}" "./repo/"
	flatpak build-update-repo --gpg-sign="${GPG_KEY}" --default-branch="stable" --prune "./repo/"

import-bundles:
	bash ./scripts/import-bundles.sh

sync-all:
	@$(MAKE) repo-init
	@$(MAKE) gpg-key-import
	@$(MAKE) import-bundles
	@$(MAKE) repo-sign
	@$(MAKE) repo-list

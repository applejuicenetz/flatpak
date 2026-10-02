#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="${REPO_DIR:-${PROJECT_ROOT}/repo}"
: "${GPG_KEY:?GPG_KEY must identify the repository signing key}"

for dependency in gh jq flatpak ostree sha256sum; do
    command -v "$dependency" >/dev/null || { printf 'Missing dependency: %s\n' "$dependency" >&2; exit 1; }
done

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$WORK_DIR/bundles"
ostree init --repo="$WORK_DIR/staging-repo" --mode=archive-z2
touch "$WORK_DIR/imports.tsv"
touch "$WORK_DIR/carry-over.txt"

queue_release() {
    local source_repo="$1" app_id="$2" prefix="$3" branch="$4" release_file="$5"
    local package_arch flatpak_arch arch_pattern asset_json asset_count asset_name asset_id asset_digest
    printf 'Source: %s %s (%s)\n' "$source_repo" "$(jq -r '.tag_name' "$release_file")" "$branch"
    for package_arch in amd64 aarch64; do
        case "$package_arch" in
            amd64) flatpak_arch=x86_64; arch_pattern='(amd64|x86_64)' ;;
            aarch64) flatpak_arch=aarch64; arch_pattern='(aarch64|arm64)' ;;
        esac
        asset_json="$(jq -c --arg pattern "^${prefix}[.-].*${arch_pattern}\\.flatpak$" \
            '[.assets[] | select(.name | test($pattern))]' "$release_file")"
        asset_count="$(jq 'length' <<< "$asset_json")"
        if [[ "$asset_count" != 1 ]]; then
            printf 'Expected exactly one %s .flatpak in %s (%s); found %s\n' \
                "$package_arch" "$source_repo" "$branch" "$asset_count" >&2
            return 1
        fi
        asset_name="$(jq -r '.[0].name' <<< "$asset_json")"
        asset_id="$(jq -r '.[0].id' <<< "$asset_json")"
        asset_digest="$(jq -r '.[0].digest // "-"' <<< "$asset_json")"
        printf '%s\t%s\t%s\t%s\t%s\n' "$source_repo" "$asset_id" "$asset_digest" \
            "${app_id}-${branch}-${flatpak_arch}.flatpak" "app/${app_id}/${flatpak_arch}/${branch}" >> "$WORK_DIR/imports.tsv"
        printf 'Bundle: %s\n' "$asset_name"
    done
}

CORE_REPO="${CORE_REPO:-applejuicenetz/core}"
COLLECTOR_REPO="${COLLECTOR_REPO:-applejuicenetz/collector}"
JAVAGUI_REPO="${JAVAGUI_REPO:-applejuicenetz/gui-java}"
PUBLISHED_REPO_URL="${PUBLISHED_REPO_URL:-https://applejuicenetz.github.io/flatpak/repo/}"
PUBLISHED_GPG_FILE="${PUBLISHED_GPG_FILE:-${PROJECT_ROOT}/repo/applejuice.gpg}"

gh api "repos/${CORE_REPO}/releases/latest" > "$WORK_DIR/core.json"
if jq -e 'any(.assets[]; .name | test("\\.flatpak$"))' "$WORK_DIR/core.json" >/dev/null; then
    queue_release "$CORE_REPO" io.github.applejuicenetz.core AJCore stable "$WORK_DIR/core.json"
else
    printf 'Core release %s has no .flatpak assets; keeping published core//stable.\n' "$(jq -r '.tag_name' "$WORK_DIR/core.json")"
    printf 'app/io.github.applejuicenetz.core/x86_64/stable\napp/io.github.applejuicenetz.core/aarch64/stable\n' >> "$WORK_DIR/carry-over.txt"
fi
gh api --paginate "repos/${CORE_REPO}/releases?per_page=100" \
    | jq -s '[.[][] | select(.draft == false and .prerelease == true)] | sort_by(.published_at) | last' \
    > "$WORK_DIR/core-beta.json"
if [[ "$(jq -r 'type' "$WORK_DIR/core-beta.json")" != null ]]; then
    queue_release "$CORE_REPO" io.github.applejuicenetz.core AJCore beta "$WORK_DIR/core-beta.json"
else
    printf 'No Core pre-release; no beta bundles imported.\n'
fi

gh api "repos/${COLLECTOR_REPO}/releases/latest" > "$WORK_DIR/collector.json"
queue_release "$COLLECTOR_REPO" io.github.applejuicenetz.collector AJCollector stable "$WORK_DIR/collector.json"
gh api "repos/${JAVAGUI_REPO}/releases/latest" > "$WORK_DIR/javagui.json"
queue_release "$JAVAGUI_REPO" io.github.applejuicenetz.javagui AJCoreGUI stable "$WORK_DIR/javagui.json"

if [[ -s "$WORK_DIR/carry-over.txt" ]]; then
    ostree init --repo="$WORK_DIR/published-repo" --mode=archive-z2
    ostree remote add --repo="$WORK_DIR/published-repo" --gpg-import="$PUBLISHED_GPG_FILE" published "$PUBLISHED_REPO_URL"
    while read -r carry_ref; do
        ostree pull --repo="$WORK_DIR/published-repo" published "$carry_ref"
        flatpak build-commit-from --src-repo="$WORK_DIR/published-repo" --src-ref="published:${carry_ref}" \
            --force --no-update-summary --gpg-sign="$GPG_KEY" "$REPO_DIR" "$carry_ref"
    done < "$WORK_DIR/carry-over.txt"
fi

while IFS=$'\t' read -r source_repo asset_id asset_digest bundle_name target_ref; do
    gh api -H 'Accept: application/octet-stream' "repos/${source_repo}/releases/assets/${asset_id}" \
        > "$WORK_DIR/bundles/$bundle_name"
    test -s "$WORK_DIR/bundles/$bundle_name"
    if [[ "$asset_digest" != - ]]; then
        [[ "$asset_digest" =~ ^sha256:[a-fA-F0-9]{64}$ ]] || { printf 'Invalid asset digest\n' >&2; exit 1; }
        printf '%s  %s\n' "${asset_digest#sha256:}" "$WORK_DIR/bundles/$bundle_name" | sha256sum --check --status
    fi
done < "$WORK_DIR/imports.tsv"

while IFS=$'\t' read -r source_repo asset_id asset_digest bundle_name target_ref; do
    flatpak build-import-bundle --no-update-summary --ref="$target_ref" \
        "$WORK_DIR/staging-repo" "$WORK_DIR/bundles/$bundle_name"
    flatpak build-commit-from --src-repo="$WORK_DIR/staging-repo" --src-ref="$target_ref" \
        --force --no-update-summary --gpg-sign="$GPG_KEY" "$REPO_DIR" "$target_ref"
done < "$WORK_DIR/imports.tsv"

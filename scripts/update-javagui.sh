#!/bin/bash

################################################################################
# appleJuice JavaGUI Flatpak Updater Script
#
# Usage: ./update-javagui.sh
#
# This script automatically updates the JavaGUI Flatpak YAML manifest and metainfo
# with the latest stable release from the appleJuice JavaGUI GitHub repo.
#
# Supported on: macOS and Linux
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# GitHub API URL
JAVAGUI_API_URL="https://api.github.com/repos/applejuicenetz/gui-java/releases"

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if jq is installed
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed."
        echo "Please install jq:"
        echo "  macOS: brew install jq"
        echo "  Linux: sudo apt-get install jq (Debian/Ubuntu) or equivalent"
        exit 1
    fi
}

# Get the latest stable release
# Arguments: $1 = API URL
get_latest_release() {
    local api_url="$1"

    curl -s "${api_url}" | jq -r \
        '.[] | select(.prerelease == false and .draft == false) | .tag_name' | head -1
}

# Get release details including download URLs and checksums
# Arguments: $1 = API URL, $2 = tag name, $3 = file pattern
get_release_details() {
    local api_url="$1"
    local tag="$2"
    local file_pattern="$3"

    local release_data=$(curl -s "${api_url}/tags/${tag}")

    local download_url=$(echo "$release_data" | jq -r \
        --arg pattern "$file_pattern" \
        '.assets[] | select(.name | test($pattern)) | .browser_download_url' | head -1)

    local sha256=$(echo "$release_data" | jq -r \
        --arg pattern "$file_pattern" \
        '.assets[] | select(.name | test($pattern)) | .digest' | head -1)

    local release_date=$(echo "$release_data" | jq -r '.published_at' | cut -d'T' -f1)

    echo "${download_url}|${sha256}|${release_date}"
}

# Update YAML file with new version
update_yaml() {
    local yaml_file="$1"
    local new_version="$2"
    local download_url="$3"
    local sha256="$4"

    if [[ ! -f "$yaml_file" ]]; then
        log_error "File not found: $yaml_file"
        return 1
    fi

    # Extract old URL
    local old_url=$(grep 'url: https://github.com/applejuicenetz/gui-java' "$yaml_file" | head -1 | awk '{print $2}')

    if [[ -z "$old_url" ]]; then
        log_error "Could not find old URL in $yaml_file"
        return 1
    fi

    # Escape special characters in URLs for sed
    local old_url_escaped=$(echo "$old_url" | sed 's/[&/\]/\\&/g')
    local new_url_escaped=$(echo "$download_url" | sed 's/[&/\]/\\&/g')

    # Replace URL
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|${old_url_escaped}|${new_url_escaped}|g" "$yaml_file"
    else
        sed -i "s|${old_url_escaped}|${new_url_escaped}|g" "$yaml_file"
    fi

    # Replace SHA256 - ONLY THE FIRST occurrence using awk
    local temp_file="${yaml_file}.tmp"
    awk -v sha="$sha256" '
        /sha256:/ && !replaced {
            sub(/sha256: [a-f0-9]+/, "sha256: " sha)
            replaced=1
        }
        { print }
    ' "$yaml_file" > "$temp_file"

    mv "$temp_file" "$yaml_file"

    log_success "Updated $yaml_file"
    log_info "  Version: $new_version"
    log_info "  URL: $download_url"
    log_info "  SHA256: $sha256"
}

# Update metainfo.xml with new version
update_metainfo() {
    local metainfo_file="$1"
    local new_version="$2"
    local release_date="$3"

    if [[ ! -f "$metainfo_file" ]]; then
        log_error "File not found: $metainfo_file"
        return 1
    fi

    # Create a temporary file for the modified content
    local temp_file="${metainfo_file}.tmp"

    # Use awk to replace the release line
    awk -v new_version="$new_version" -v release_date="$release_date" '
        /<release / {
            print "        <release version=\"" new_version "\" type=\"stable\" date=\"" release_date "\"/>"
            next
        }
        { print }
    ' "$metainfo_file" > "$temp_file"

    # Replace the original file
    mv "$temp_file" "$metainfo_file"

    log_success "Updated $metainfo_file"
    log_info "  Version: $new_version"
    log_info "  Release Type: stable"
    log_info "  Date: $release_date"
}

# Display summary
display_summary() {
    echo
    log_info "=========================================="
    log_info "appleJuice JavaGUI Flatpak Updater"
    log_info "=========================================="
    log_info "Release Type: STABLE"
    echo
}

################################################################################
# Main Script
################################################################################

main() {
    local YAML_FILE="${PROJECT_ROOT}/flatpak/io.github.applejuicenetz.javagui.yaml"
    local METAINFO_FILE="${PROJECT_ROOT}/flatpak/javagui/io.github.applejuicenetz.javagui.metainfo.xml"

    # Check dependencies
    check_dependencies

    # Display summary
    display_summary

    # Get latest version
    log_info "Fetching latest stable version from GitHub..."
    local javagui_version=$(get_latest_release "$JAVAGUI_API_URL")

    if [[ -z "$javagui_version" ]]; then
        log_error "Could not find stable version for JavaGUI"
        exit 1
    fi

    log_success "Found JavaGUI version: $javagui_version"

    # Get download details
    log_info "Fetching release details..."
    local javagui_details=$(get_release_details "$JAVAGUI_API_URL" "$javagui_version" "AJCoreGUI.*\.zip")

    if [[ -z "$javagui_details" ]]; then
        log_error "Could not retrieve release details"
        exit 1
    fi

    IFS='|' read -r javagui_url javagui_sha256 javagui_date <<< "$javagui_details"

    if [[ -z "$javagui_url" || -z "$javagui_sha256" || -z "$javagui_date" ]]; then
        log_error "Could not parse download URL, SHA256, or release date"
        exit 1
    fi

    # Remove "sha256:" prefix if present
    javagui_sha256="${javagui_sha256#sha256:}"

    # Update YAML
    log_info "Updating YAML manifest..."
    update_yaml "$YAML_FILE" "$javagui_version" "$javagui_url" "$javagui_sha256"

    echo

    # Update metainfo.xml
    log_info "Updating metainfo.xml..."
    update_metainfo "$METAINFO_FILE" "$javagui_version" "$javagui_date"

    echo
    log_success "Update complete!"
    echo
}

# Run main function
main "$@"


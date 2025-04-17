#!/bin/bash

# PlayStore Build Script
# Description: Creates an Android App Bundle (AAB) for Play Store release from a selected tag.
# Usage: ./create-playstore-build.sh [--info]
#   --info    Only displays information about the script without running it

# Check if --info flag is passed
if [[ "$1" == "--info" ]]; then
	echo "PlayStore Build Script"
	echo "Description: Creates an Android App Bundle (AAB) for Play Store release from a selected tag."
	echo "This script will:"
	echo "  1. Fetch available tags from git"
	echo "  2. Allow selection of a release tag"
	echo "  3. Checkout the selected tag"
	echo "  4. Build an Android App Bundle (AAB) for Play Store submission"
	echo "  5. Optionally copy the AAB to Downloads folder"
	echo "  6. Return to the original branch on completion"
	exit 0
fi

cd "$(dirname "$(realpath "$0")")" || exit
source ./go-root.sh
set -e
# Check for uncommitted changes
if [[ -n "$(git status --porcelain)" ]]; then
	gum log --structured --level error "Uncommitted changes found in repository. Please commit or stash them before releasing."
	git status
	exit 1
fi

# Save the current branch name
ORIGINAL_BRANCH=$(git branch --show-current)

# This will run even if the script exits with an error or is interrupted
cleanup() {
	./release-automation/android/post-release.sh
	echo "Switching back to original branch: $ORIGINAL_BRANCH"
	git switch "$ORIGINAL_BRANCH" 2>/dev/null || true
}

# Set up trap for script exit (normal exit, error, or interrupt)
trap cleanup EXIT

# Check for uncommitted changes
# if [[ -n "$(git status --porcelain)" ]]; then
# 	gum log --structured --level error "Uncommitted changes found in repository. Please commit or stash them before releasing."
# 	git status
# 	exit 1
# fi

if ! command -v gum &>/dev/null; then
	echo "gum is not installed. Please install it first: https://github.com/charmbracelet/gum"
	exit 1
fi

git fetch --tags

# Get the last 10 tags
tags=$(git tag --sort=-creatordate | head -n 10)

# Check if there are tags
if [ -z "$tags" ]; then
	echo "No tags found in the repository."
	exit 1
fi

# Use gum to select a tag
echo "Select a tag to release:"
selected_tag=$(echo "$tags" | gum choose)

# Check if a tag was selected
if [ -z "$selected_tag" ]; then
	echo "No tag selected. Exiting."
	exit 1
fi

# Checkout to the selected tag
echo "Checking out to tag: $selected_tag"
git checkout "$selected_tag"

./release-automation/android/pre-release.sh

gum log --structured --level debug "Compiling"

OUTPUT_FILE="app/build/outputs/bundle/release/app-release.aab"

APP_NAME=$(basename "$(pwd)")
DOWNLOADS_OUTPUT_NAME="$APP_NAME-play-store-release.aab"
./gradlew bundleRelease

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Release is complete!' 'Version is: '"$selected_tag"

gum confirm "Do you want to copy to Downloads?" && cp "$OUTPUT_FILE" "$HOME/Downloads/$DOWNLOADS_OUTPUT_NAME"

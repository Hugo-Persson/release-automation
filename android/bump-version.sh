#!/bin/bash

# Version Bump Script
# Description: Increments app version (patch, minor, major) and version code in build.gradle.kts.
# Usage: ./bump-version.sh [--info]
#   --info    Only displays information about the script without running it

# Check if --info flag is passed
if [[ "$1" == "--info" ]]; then
	echo "Version Bump Script"
	echo "Description: Increments app version (patch, minor, major) and version code in build.gradle.kts and commits the changes."
	echo "This script will:"
	echo "  - Extract current version name and version code from build.gradle.kts"
	echo "  - Allow selection of version bump type (patch, minor, or major)"
	echo "  - Calculate the new version using semver"
	echo "  - Update version name and version code in build.gradle.kts"
	echo "  - Commit the changes to git with a version bump message"
	exit 0
fi

cd "$(dirname "$(realpath "$0")")" || exit
source ./go-root.sh
FILE="./app/build.gradle.kts"
# Extract the current values using grep

VERSION_NAME=$(grep 'versionName = ' $FILE | awk -F '"' '{print $2}')
CURRENT_VERSION_CODE=$(grep 'versionCode' $FILE | grep -o '[0-9]\+')

gum log --structured --level debug "Current version is" version "$VERSION_NAME" "with version code" "$CURRENT_VERSION_CODE"
echo "What type of release?"
TYPE=$(gum choose "patch" "minor" "major")
NEW_VERSION=$(semver -i "$TYPE" "$VERSION_NAME")
NEW_VERSION_CODE=$((CURRENT_VERSION_CODE + 1))
gum log --structured --level debug "New version is" version "$NEW_VERSION" "with version code" $NEW_VERSION_CODE

sed -i '' "s/versionCode .*/versionCode = $NEW_VERSION_CODE/" "$FILE"
sed -i '' "s/versionName .*/versionName = \"$NEW_VERSION\"/" "$FILE"

git add "$FILE"
git commit -m "chore: bump version to $NEW_VERSION"

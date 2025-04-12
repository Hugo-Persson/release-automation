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

# Read theme from slam.properties
SLAM_PROPS_FILE="slam.properties"
THEME=$(grep "theme=" "$SLAM_PROPS_FILE" | cut -d'=' -f2)

gum log --structured --level debug "Detected theme" theme "$THEME"

GRADLE_FILE="./app/build.gradle.kts"

# Determine which theme version to update based on the theme in slam.properties
case "$THEME" in
  "combain")
    VERSION_PATTERN="val combainTheme = ThemeBuildConfig"
    ;;
  "traxmate")
    VERSION_PATTERN="val traxmateTheme = ThemeBuildConfig"
    ;;
  "lifefinder")
    VERSION_PATTERN="val lifefinderTheme = ThemeBuildConfig"
    ;;
  *)
    gum log --structured --level error "Unknown theme:" "$THEME"
    exit 1
    ;;
esac

# Extract the current values
VERSION_LINE=$(grep "$VERSION_PATTERN" "$GRADLE_FILE")
VERSION_NAME=$(echo "$VERSION_LINE" | grep -o '"[0-9]\+\.[0-9]\+\.[0-9]\+"' | tr -d '"')
CURRENT_VERSION_CODE=$(echo "$VERSION_LINE" | grep -o ', [0-9]\+)' | grep -o '[0-9]\+')

gum log --structured --level debug "Current version is" version "$VERSION_NAME" "with version code" "$CURRENT_VERSION_CODE"

echo "What type of release?"
TYPE=$(gum choose "patch" "minor" "major")
NEW_VERSION=$(semver -i "$TYPE" "$VERSION_NAME")
NEW_VERSION_CODE=$((CURRENT_VERSION_CODE + 1))
gum log --structured --level debug "New version is" version "$NEW_VERSION" "with version code" $NEW_VERSION_CODE

# Update the version in build.gradle.kts for the specific theme
sed -i '' "s/$VERSION_PATTERN(\"$VERSION_NAME\", $CURRENT_VERSION_CODE)/$VERSION_PATTERN(\"$NEW_VERSION\", $NEW_VERSION_CODE)/" "$GRADLE_FILE"

git add "$GRADLE_FILE"
git commit -m "chore: bump $THEME version to $NEW_VERSION"
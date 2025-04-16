#!/bin/bash

# Release Script
# Description: Creates a production release with version tagging and changelog generation.
# Usage: ./release.sh [--info]
#   --info    Only displays information about the script without running it

# Check if --info flag is passed
if [[ "$1" == "--info" ]]; then
	echo "Release Script"
	echo "Description: Creates a production release with version tagging and changelog generation."
	echo "This script will:"
	echo "  - Build the project"
	echo "  - Generate a changelog with git-cliff"
	echo "  - Commit, tag, and push the release"
	echo "  - Build a release APK"
	echo "  - Optionally copy the APK to Downloads folder"
	echo "  - Automatically bump the version for next development cycle and commits, see bump-version.sh"
	exit 0
fi

cd "$(dirname "$(realpath "$0")")" || exit
SCRIPT_DIR="$(pwd)"
IS_SLAM=$(./is-slam.sh)
source ./go-root.sh

if [[ -n "$(sed -n '/useLocalSDK=true/p' slam.properties)" ]]; then
	# If useLocalSDK is true, execute the block of code
	gum log --structured --level error "useLocalSDK is true in file, not allowed, exiting" file slam.properties
	exit 1
fi

# Check for uncommitted changes
if [[ -n "$(git status --porcelain)" ]]; then
	gum log --structured --level error "Uncommitted changes found in repository. Please commit or stash them before releasing."
	git status
	exit 1
fi

gum log --structured --level debug "Building project"
if ! ./gradlew build; then
	gum log --level error "The build failed with a non-zero exit code."
	exit 1
fi

FILE="./app/build.gradle.kts"
VERSION_NAME=$(grep 'versionName = ' "$FILE" | awk -F '"' '{print $2}')
gum log --level info "The build succeeded." version "$VERSION_NAME"

preform_release() {

	gum log --structured --level debug "Compiling and publishing"

	git cliff $CLIFF_ARGS --tag "$VERSION_NAME" -o CHANGELOG.md
	git add CHANGELOG.md

	if $IS_SLAM; then
		SLAM_SDK_VERSION=$(sed -n 's/.*var slamSDKVersion = "\([^"]*\)".*/\1/p' "$FILE")
		git commit -m "chore(publishing): $VERSION_NAME - SlamSDK = $SLAM_SDK_VERSION"
		git tag -a "v$VERSION_NAME" -m "Release version v$VERSION_NAME"
	else
		git commit -m "chore(publishing): $VERSION_NAME"
		git tag -a "v$VERSION_NAME" -m "Release version v$VERSION_NAME"
	fi

	git push origin --tags
	git push

	./release-automation/android/pre-release.sh
	./gradlew assembleRelease
	./release-automation/android/post-release.sh

	gum style \
		--foreground 212 --border-foreground 212 --border double \
		--align center --width 50 --margin "1 2" --padding "2 4" \
		"v$VERSION_NAME" 'Release is complete!'

	APP_NAME=$(basename "$(pwd)")
	gum confirm "Do you want to copy to Downloads?" && cp app/build/outputs/apk/release/app-release.apk "$HOME/Downloads/$APP_NAME-$VERSION_NAME.apk"
	gum log --structured --level debug "Running standard version bump"
	"$SCRIPT_DIR/bump-version.sh"

}
gum confirm "Do you want to preform release?" && preform_release

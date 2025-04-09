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
else
	gum log --level info "The build succeeded."
fi

preform_release() {

	FILE="./app/build.gradle.kts"

	VERSION=$(grep 'versionName = ' $FILE | awk -F '"' '{print $2}')

	gum log --structured --level debug "Compiling and publishing"

	git cliff $CLIFF_ARGS --tag "$VERSION" -o CHANGELOG.md
	git add CHANGELOG.md

	if is_slam; then
		SLAM_SDK_VERSION=$(sed -n 's/.*var slamSDKVersion = "\([^"]*\)".*/\1/p' "$FILE")
		git commit -m "chore(publishing): $VERSION - SlamSDK = $SLAM_SDK_VERSION"
		git tag -a "v$VERSION" -m "Release version v$VERSION"
	else
		git commit -m "chore(publishing): $VERSION"
		git tag -a "v$VERSION" -m "Release version v$VERSION"
	fi

	git push origin --tags
	git push

	./gradlew assembleRelease

	gum style \
		--foreground 212 --border-foreground 212 --border double \
		--align center --width 50 --margin "1 2" --padding "2 4" \
		"v$VERSION" 'Release is complete!'
	gum confirm "Do you want to copy to Downloads?" && cp app/build/outputs/apk/release/app-release.apk "$HOME/Downloads/demo-app-$VERSION.apk"
	./scripts/bump-version.sh

}
gum confirm "Do you want to preform release?" && preform_release

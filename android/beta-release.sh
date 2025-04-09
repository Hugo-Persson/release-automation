#!/bin/bash

# Beta Release Script
# Description: Creates a beta release APK with incremented version code.
# Usage: ./beta-release.sh [--info]
#   --info    Only displays information about the script without running it

# Check if --info flag is passed
if [[ "$1" == "--info" ]]; then
	echo "Beta Release Script"
	echo "Description: Creates a beta release APK with incremented version code."
	echo "The difference between this and release is that we allow uncommitted changes and local SDK"
	echo "This script will:"
	echo "  1. Increment the versionCode in build.gradle.kts"
	echo "  2. Build a release APK"
	echo "  3. Optionally copy the APK to the Downloads folder as 'beta.apk'"
	exit 0
fi

cd "$(dirname "$(realpath "$0")")" || exit
./go-root.sh
pwd
set -e

OUTPUT_FILE="app/build/outputs/apk/release/app-release.apk"

DOWNLOADS_OUTPUT_NAME="beta.apk"

RELEASE_FILE="./app/build.gradle.kts"
VERSION_CODE=$(grep 'versionCode' $RELEASE_FILE | grep -o '[0-9]\+')

echo "What type of release?"
NEW_VERSION_CODE=$(($VERSION_CODE + 1))

echo "New version code is $NEW_VERSION_CODE"
gum log --structured --level debug "Compiling and publishing"
sed -i '' "s/versionCode = .*/versionCode = $NEW_VERSION_CODE/" $RELEASE_FILE

./gradlew assembleRelease

rm -f "$HOME/Downloads/$DOWNLOADS_OUTPUT_NAME"

gum confirm "Do you want to copy to Downloads?" && cp "$OUTPUT_FILE" "$HOME/Downloads/$DOWNLOADS_OUTPUT_NAME"

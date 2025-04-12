#!/bin/bash

cd "$(dirname "$(realpath "$0")")" || exit
source ./go-root.sh
pwd
set -e

OUTPUT_FILE="app/build/outputs/apk/release/app-release.apk"

DOWNLOADS_OUTPUT_NAME="draft.apk"

./gradlew assembleRelease

rm -f "$HOME/Downloads/$DOWNLOADS_OUTPUT_NAME"

gum confirm "Do you want to copy to Downloads?" && cp "$OUTPUT_FILE" "$HOME/Downloads/$DOWNLOADS_OUTPUT_NAME"

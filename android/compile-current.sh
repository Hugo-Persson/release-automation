#!/bin/bash

cd "$(dirname "$(realpath "$0")")" || exit
# SCRIPT_DIR="$(pwd)"
# IS_SLAM=$(./is-slam.sh)
source ./go-root.sh

./release-automation/android/pre-release.sh
./gradlew assembleRelease
./release-automation/android/post-release.sh

echo "App compiled successfully. The APK is located in "
echo "./app/build/outputs/apk/release/app-release.apk"

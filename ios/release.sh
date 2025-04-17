#!/bin/bash
set -e

# Navigate to project root
cd "$(dirname "$0")"
source ./go-root.sh

# Check if the working directory is clean
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: Working directory is not clean. Commit or stash changes first."
  exit 1
fi

# Get current version from Config.xcconfig
CONFIG_PATH="Config.xcconfig"
./release-automation/ios/config_check.sh

# Read version from Config.xcconfig
CURRENT_VERSION=$(grep "MARKETING_VERSION" $CONFIG_PATH | cut -d "=" -f2 | tr -d '[:space:]')
CURRENT_BUILD=$(grep "CURRENT_PROJECT_VERSION" $CONFIG_PATH | cut -d "=" -f2 | tr -d '[:space:]')

echo "Current version: $CURRENT_VERSION ($CURRENT_BUILD)"

# Increment build number in Config.xcconfig
NEW_BUILD=$(echo "$CURRENT_BUILD + 0.1" | bc)
sed -i '' "s/CURRENT_PROJECT_VERSION  = $CURRENT_BUILD/CURRENT_PROJECT_VERSION  = $NEW_BUILD/" $CONFIG_PATH

# Ask if version should be incremented
read -p "Increment version number as well? (y/n): " INCREMENT_VERSION
if [[ $INCREMENT_VERSION == "y" || $INCREMENT_VERSION == "Y" ]]; then
  # Split the version string by dots
  IFS='.' read -ra VERSION_PARTS <<<"$CURRENT_VERSION"
  # Increment the last part
  LAST_INDEX=$((${#VERSION_PARTS[@]} - 1))
  VERSION_PARTS[$LAST_INDEX]=$((VERSION_PARTS[LAST_INDEX] + 1))
  # Join the version parts back together
  NEW_VERSION=$(
    IFS='.'
    echo "${VERSION_PARTS[*]}"
  )

  # Update version in Config.xcconfig
  sed -i '' "s/MARKETING_VERSION = $CURRENT_VERSION/MARKETING_VERSION = $NEW_VERSION/" $CONFIG_PATH

  echo "Incremented version to $NEW_VERSION ($NEW_BUILD)"
else
  NEW_VERSION=$CURRENT_VERSION
  echo "Kept version at $NEW_VERSION, incremented build to $NEW_BUILD"
fi

# Commit the version changes
git add $CONFIG_PATH
git commit -m "Bump version to $NEW_VERSION ($NEW_BUILD)"

# Archive and upload to TestFlight
echo "Archiving and uploading to TestFlight..."
# TODO: Get scheme from ENV
xcodebuild -scheme karoliner -configuration Release archive -archivePath build/karoliner.xcarchive

open build/*.xcarchive

echo "Done! Version $NEW_VERSION ($NEW_BUILD)"

#!/bin/bash

# Root Navigation Script
# Description: Navigates to the project root directory containing the gradle folder.
# Usage: ./go-root.sh [--info]
#   --info    Only displays information about the script without running it

# Check if --info flag is passed
if [[ "$1" == "--info" ]]; then
  echo "Root Navigation Script"
  echo "Description: Navigates to the project root directory containing the xcodeproj folder."
  echo "This script will:"
  echo "  1. Navigate up from the current directory until it finds a directory with a '*.xcodeproj' folder"
  echo "  2. Exit with an error if no directory containing a 'gradle' folder is found"
  echo "Note: This script is typically sourced by other scripts to ensure they run from the project root"
  exit 0
fi
# Check if go-root.sh exists in the current directory
if [[ ! -f "$(pwd)/go-root.sh" ]]; then
  cd "$(dirname "$(realpath "$0")")" || exit
fi
while [[ -z "$(find . -maxdepth 1 -type d -name "*.xcodeproj")" && "$(pwd)" != "/" ]]; do
  cd ..
done

XCODE_PROJ=$(find . -maxdepth 1 -type d -name "*.xcodeproj")
if [[ -z "$XCODE_PROJ" ]]; then
  echo "Error: Could not find any Xcode project directory" >&2
  exit 1
fi

echo "Found Xcode project: $XCODE_PROJ"
pwd

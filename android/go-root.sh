#!/bin/bash

# Root Navigation Script
# Description: Navigates to the project root directory containing the gradle folder.
# Usage: ./go-root.sh [--info]
#   --info    Only displays information about the script without running it

# Check if --info flag is passed
if [[ "$1" == "--info" ]]; then
	echo "Root Navigation Script"
	echo "Description: Navigates to the project root directory containing the gradle folder."
	echo "This script will:"
	echo "  1. Navigate up from the current directory until it finds a directory with a 'gradle' folder"
	echo "  2. Exit with an error if no directory containing a 'gradle' folder is found"
	echo "Note: This script is typically sourced by other scripts to ensure they run from the project root"
	exit 0
fi

cd "$(dirname "$(realpath "$0")")" || exit
while [[ ! -d "gradle" && "$(pwd)" != "/" ]]; do
	cd ..
done

if [[ ! -d "gradle" ]]; then
	echo "Error: Could not find directory with gradle folder" >&2
	exit 1
fi

pwd

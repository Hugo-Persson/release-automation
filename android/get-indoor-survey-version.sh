#!/bin/bash
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
VERSION_LINE=$(grep "$VERSION_PATTERN" "$GRADLE_FILE")
if [[ -z "$VERSION_LINE" ]]; then
	gum log --structured --level error "Failed to find version pattern in gradle file"
	exit 1
fi
export VERSION_LINE

VERSION_NAME=$(echo "$VERSION_LINE" | grep -o '"[0-9]\+\.[0-9]\+\.[0-9]\+"' | tr -d '"')
if [[ -z "$VERSION_NAME" ]]; then
	gum log --structured --level error "Failed to extract version"
	exit 1
fi
export VERSION_NAME


# Check if pre-build script exists and run it if found
PRE_BUILD_SCRIPT="./pre-playstore-build.sh"
if [[ -f "$PRE_BUILD_SCRIPT" ]]; then
	gum log --structured --level info "Running pre-build script"
	bash "$PRE_BUILD_SCRIPT"
	if [[ $? -ne 0 ]]; then
		gum log --structured --level error "Pre-build script failed. Aborting build."
		exit 1
	fi
else
	gum log --structured --level debug "No pre-build script found, continuing with build"
fi

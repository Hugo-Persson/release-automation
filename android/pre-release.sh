# Check if pre-build script exists and run it if found
PRE_RELEASE_SCRIPT="./pre-release.sh"
if [[ -f "$PRE_RELEASE_SCRIPT" ]]; then
	gum log --structured --level info "Running pre-release script"
	bash "$PRE_RELEASE_SCRIPT"
	if [[ $? -ne 0 ]]; then
		gum log --structured --level error "Pre-release script failed. Aborting build."
		exit 1
	fi
else
	gum log --structured --level debug "No pre-release script found, continuing with build"
fi

# Check if post-build script exists and run it if found
POST_BUILD_SCRIPT="./post-playstore-build.sh"
if [[ -f "$POST_BUILD_SCRIPT" ]]; then
	gum log --structured --level info "Running post-build script"
	bash "$POST_BUILD_SCRIPT"
	if [[ $? -ne 0 ]]; then
		gum log --structured --level warn "Post-build script completed with errors"
	fi
else
	gum log --structured --level debug "No post-build script found"
fi

# Check if post-build script exists and run it if found
POST_RELEASE_SCRIPT="./post-release.sh"
if [[ -f "$POST_RELEASE_SCRIPT" ]]; then
	gum log --structured --level info "Running post-release script"
	bash "$POST_RELEASE_SCRIPT"
	if [[ $? -ne 0 ]]; then
		gum log --structured --level warn "Post-release script completed with errors"
	fi
else
	gum log --structured --level debug "No post-release script found"
fi

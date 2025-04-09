#!/bin/bash

# SLAM Properties Check Script
# Description: Checks if slam.properties file exists in the current directory.
# Usage: ./is-slam.sh [--info]
#   --info    Only displays information about the script without running it
# Example usage in an if statement:
# if is_slam; then
#   echo "slam.properties exists, performing SLAM operations"
# else
#   echo "slam.properties not found, using regular mode"
# fi

# Check if --info flag is passed
if [[ "$1" == "--info" ]]; then
	echo "Checks if this project is using SlamSDK"
	echo "Description: Checks if slam.properties file exists in the current directory."
	exit 0
fi

# Function to check if slam.properties exists
is_slam() {
	if [ -f "slam.properties" ]; then
		return 0 # Return true (0 is success in bash)
	else
		return 1 # Return false (non-zero is failure in bash)
	fi
}

# Execute the function
is_slam

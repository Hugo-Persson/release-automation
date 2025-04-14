#!/bin/bash

CONFIG_PATH="Config.xcconfig"

# Check if file exists
if [ ! -f "$CONFIG_PATH" ]; then
  echo "Error: Config file '$CONFIG_PATH' does not exist."
  exit 1
fi

# Check if file is readable
if [ ! -r "$CONFIG_PATH" ]; then
  echo "Error: Config file '$CONFIG_PATH' is not readable."
  exit 1
fi

# Optional: Display file contents for verification
echo "Config file found and readable. Contents:"
cat "$CONFIG_PATH"

exit 0

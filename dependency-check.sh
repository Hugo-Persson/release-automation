#!/usr/bin/env bash
set -euo pipefail

check_dependency() {
    local cmd=$1
    local install_url=$2
    
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ $cmd is not installed"
        echo "   Please install it from: $install_url"
        return 1
    else
        echo "✅ $cmd is installed"
        return 0
    fi
}

echo "Checking dependencies..."

errors=0

# Check for semver
check_dependency "semver" "https://www.npmjs.com/package/semver" || ((errors++))

# Check for gum
check_dependency "gum" "https://github.com/charmbracelet/gum#installation" || ((errors++))

if [ $errors -gt 0 ]; then
    echo "Missing dependencies. Please install them before continuing."
    exit 1
else
    echo "All dependencies are installed! ✨"
fi
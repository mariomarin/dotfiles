#!/usr/bin/env bash
# Smart commit handler for chezmoi changes

set -uo pipefail  # Remove 'e' flag to not fail on command errors

# Skip if disabled
if [[ "${CHEZMOI_SMART_COMMIT:-true}" == "false" ]]; then
    echo "ℹ️  Smart commit disabled (CHEZMOI_SMART_COMMIT=false)"
    exit 0
fi

# Check if script exists in the expected location
SMART_COMMIT_SCRIPT="$HOME/.local/bin/chezmoi-smart-commit"
if [[ -x "$SMART_COMMIT_SCRIPT" ]]; then
    "$SMART_COMMIT_SCRIPT" || true  # Always succeed
elif command -v chezmoi-smart-commit > /dev/null 2>&1; then
    chezmoi-smart-commit || true  # Always succeed
else
    echo "ℹ️  Smart commit not yet available (will be after this apply)"
fi

# Always exit successfully
exit 0

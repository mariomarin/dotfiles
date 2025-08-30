#!/usr/bin/env bash
# Smart commit handler for chezmoi changes

set -euo pipefail

# Skip if disabled
if [[ "${CHEZMOI_SMART_COMMIT:-true}" == "false" ]]; then
    echo "ℹ️  Smart commit disabled (CHEZMOI_SMART_COMMIT=false)"
    exit 0
fi

# Only run if we have the smart commit script
if command -v chezmoi-smart-commit > /dev/null 2>&1; then
    chezmoi-smart-commit
else
    echo "⚠️  Smart commit not available, using standard chezmoi commit"
fi

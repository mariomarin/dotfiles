#!/usr/bin/env bash
# Install TPM plugins on first chezmoi apply

set -euo pipefail

TPM_DIR="${HOME}/.local/share/tmux/plugins/tpm"
INSTALL_SCRIPT="${TPM_DIR}/bin/install_plugins"

# Skip if TPM not installed yet (chezmoi external hasn't run)
if [[ ! -x "$INSTALL_SCRIPT" ]]; then
  echo "TPM not installed yet, skipping plugin installation"
  exit 0
fi

# Install plugins non-interactively
echo "Installing tmux plugins via TPM..."
"$INSTALL_SCRIPT"

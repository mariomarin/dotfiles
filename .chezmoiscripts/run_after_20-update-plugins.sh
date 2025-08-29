#!/bin/bash
# Update plugins for Neovim, Tmux, and Zim after chezmoi apply
# This runs after dotfiles are updated to ensure plugins stay in sync

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we should skip updates (for quick applies)
if [[ "${CHEZMOI_SKIP_PLUGIN_UPDATES:-}" == "1" ]]; then
    echo "Skipping plugin updates (CHEZMOI_SKIP_PLUGIN_UPDATES=1)"
    exit 0
fi

echo -e "${BLUE}🔄 Updating plugins...${NC}"

# Update Neovim plugins (LazyVim)
if command -v nvim &>/dev/null; then
    echo -e "${GREEN}📦 Updating Neovim plugins...${NC}"
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Neovim plugin update failed (non-critical)${NC}"
    }
fi

# Update Tmux plugins (TPM)
if [[ -d "$HOME/.local/share/tmux/plugins/tpm" ]]; then
    echo -e "${GREEN}📦 Updating Tmux plugins...${NC}"
    "$HOME/.local/share/tmux/plugins/tpm/bin/update_plugins" all 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Tmux plugin update failed (non-critical)${NC}"
    }
fi

# Update Zim modules
if command -v zimfw &>/dev/null; then
    echo -e "${GREEN}📦 Updating Zim modules...${NC}"
    zimfw update 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Zim module update failed (non-critical)${NC}"
    }
fi

echo -e "${GREEN}✅ Plugin updates complete!${NC}"
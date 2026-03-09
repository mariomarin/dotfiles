#!/usr/bin/env nu
# Install Nix packages for linux-apt via just
# hash: {{ include "nix/common/modules/cli-tools.nix" | sha256sum }}

# Check if required tools are available
if (which nix | is-empty) {
    print "⚠️  Nix not installed - skipping"
    exit 0
}

if (which just | is-empty) {
    print "⚠️  just not installed - skipping"
    exit 0
}

let chezmoi_root = (chezmoi source-path)

# Run package installation via justfile
cd $"($chezmoi_root)/nix/nixos"
just linux-apt

#!/usr/bin/env bash
# Bootstrap nushell before other apt scripts can run
set -euo pipefail

command -v nu &> /dev/null && exit 0

echo "Installing nushell from Gemfury..."
KEY_FILE="/etc/apt/keyrings/fury-nushell.gpg"

if [[ ! -f "$KEY_FILE" ]]; then
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://apt.fury.io/nushell/gpg.key | sudo gpg --dearmor -o "$KEY_FILE"
    echo "deb [signed-by=$KEY_FILE] https://apt.fury.io/nushell/ /" |
        sudo tee /etc/apt/sources.list.d/nushell.list > /dev/null
    sudo apt-get update -qq
fi

sudo apt-get install -y -qq nushell

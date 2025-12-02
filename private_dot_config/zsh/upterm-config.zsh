#!/usr/bin/env zsh
# Upterm configuration for secure terminal sharing

# Use WebSocket protocol for better firewall compatibility
# This works better through corporate firewalls that may block SSH port 22
export UPTERM_SERVER=wss://uptermd.upterm.dev

# NixOS rebuild commands
.PHONY: switch test boot build health

switch:
	sudo nixos-rebuild switch --flake .#nixos

test:
	sudo nixos-rebuild test --flake .#nixos

boot:
	sudo nixos-rebuild boot --flake .#nixos

build:
	sudo nixos-rebuild build --flake .#nixos

# Flake management
update:
	nix flake update

check:
	nix flake check

show:
	nix flake show

# Health check
health:
	@echo "🔍 NixOS Health Check"
	@echo "===================="
	@echo -n "✓ NixOS version: "; nixos-version
	@echo -n "✓ Current generation: "; sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -1
	@echo -n "✓ Flake status: "; test -f flake.lock && echo "locked" || echo "⚠️  not locked"
	@echo -n "✓ Configuration syntax: "; nix-instantiate --parse configuration.nix > /dev/null 2>&1 && echo "valid" || echo "❌ invalid"
	@echo -n "✓ Flake check: "; nix flake check --no-build 2>/dev/null && echo "passed" || echo "⚠️  warnings"
	@echo -n "✓ Nix daemon: "; systemctl is-active nix-daemon.service || echo "not running"
	@echo -n "✓ Disk usage: "; du -sh /nix/store 2>/dev/null | cut -f1
	@echo ""

# Default target
all: switch
# NixOS rebuild commands for multi-machine setup
# All targets are phony
.PHONY: $(shell sed -n -e '/^[^[:space:]#.*][^:=]*:/{s/:.*//;p}' $(MAKEFILE_LIST))

# Default host (physical T470)
HOST ?= nixos

# Remote deployment settings
TARGET_HOST ?=
BUILD_HOST ?=

# Local build and switch commands
switch:
	sudo nixos-rebuild switch --flake .#$(HOST)

test:
	sudo nixos-rebuild test --flake .#$(HOST)

boot:
	sudo nixos-rebuild boot --flake .#$(HOST)

build:
	sudo nixos-rebuild build --flake .#$(HOST)

# VM-specific targets
vm/switch:
	sudo nixos-rebuild switch --flake .#vm-headless

vm/test:
	sudo nixos-rebuild test --flake .#vm-headless

vm/build:
	sudo nixos-rebuild build --flake .#vm-headless

# Remote deployment targets
remote/switch:
	@if [ -z "$(TARGET_HOST)" ]; then \
		echo "Error: TARGET_HOST not set. Usage: make remote/switch TARGET_HOST=user@host"; \
		exit 1; \
	fi
	nixos-rebuild switch --flake .#$(HOST) \
		--target-host $(TARGET_HOST) \
		--use-remote-sudo \
		$(if $(BUILD_HOST),--build-host $(BUILD_HOST))

remote/test:
	@if [ -z "$(TARGET_HOST)" ]; then \
		echo "Error: TARGET_HOST not set. Usage: make remote/test TARGET_HOST=user@host"; \
		exit 1; \
	fi
	nixos-rebuild test --flake .#$(HOST) \
		--target-host $(TARGET_HOST) \
		--use-remote-sudo \
		$(if $(BUILD_HOST),--build-host $(BUILD_HOST))

# Deploy VM configuration to remote host
deploy-vm:
	@if [ -z "$(TARGET_HOST)" ]; then \
		echo "Error: TARGET_HOST not set. Usage: make deploy-vm TARGET_HOST=user@host"; \
		exit 1; \
	fi
	nixos-rebuild switch --flake .#vm-headless \
		--target-host $(TARGET_HOST) \
		--use-remote-sudo \
		$(if $(BUILD_HOST),--build-host $(BUILD_HOST))

# Flake management
update:
	nix flake update

check:
	nix flake check

show:
	nix flake show

# Show available hosts
hosts:
	@echo "Available NixOS configurations:"
	@echo "  - nixos       : ThinkPad T470 (desktop)"
	@echo "  - vm-headless : Headless VM (SSH only)"
	@echo ""
	@echo "Current HOST: $(HOST)"

# Health check (updated for multi-machine)
health:
	@echo "🔍 NixOS Health Check for $(HOST)"
	@echo "================================"
	@echo -n "✓ NixOS version: "; nixos-version
	@echo -n "✓ Hostname: "; hostname
	@echo -n "✓ Current generation: "; sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -1
	@echo -n "✓ Flake status: "; test -f flake.lock && echo "locked" || echo "⚠️  not locked"
	@echo -n "✓ Configuration syntax: "; nix-instantiate --parse configuration.nix > /dev/null 2>&1 && echo "valid" || echo "❌ invalid"
	@echo -n "✓ Flake check: "; nix flake check --no-build 2>/dev/null && echo "passed" || echo "⚠️  warnings"
	@echo -n "✓ Nix daemon: "; systemctl is-active nix-daemon.service || echo "not running"
	@echo -n "✓ Disk usage: "; du -sh /nix/store 2>/dev/null | cut -f1
	@echo ""

# Help target
help:
	@echo "NixOS Multi-Machine Build Targets"
	@echo "================================="
	@echo ""
	@echo "Local builds (default HOST=nixos):"
	@echo "  make switch              # Build and switch to HOST configuration"
	@echo "  make test                # Test HOST configuration"
	@echo "  make boot                # Update boot configuration"
	@echo "  make build               # Build without switching"
	@echo "  make HOST=vm-headless switch  # Build vm-headless locally"
	@echo ""
	@echo "VM-specific shortcuts:"
	@echo "  make vm/switch           # Build and switch to vm-headless"
	@echo "  make vm/test             # Test vm-headless configuration"
	@echo ""
	@echo "Remote deployment:"
	@echo "  make remote/switch TARGET_HOST=user@host    # Deploy HOST to remote"
	@echo "  make deploy-vm TARGET_HOST=user@vm-ip       # Deploy VM config"
	@echo "  make remote/test TARGET_HOST=user@host      # Test on remote"
	@echo ""
	@echo "Optional: BUILD_HOST=user@build-server for remote building"
	@echo ""
	@echo "Utilities:"
	@echo "  make hosts               # Show available configurations"
	@echo "  make health              # System health check"
	@echo "  make update              # Update flake inputs"
	@echo "  make check               # Validate flake"
	@echo ""
	@echo "Examples:"
	@echo "  make switch                                  # Local T470"
	@echo "  make vm/switch                               # Local VM config"
	@echo "  make deploy-vm TARGET_HOST=admin@192.168.1.100"
	@echo "  make remote/switch HOST=nixos TARGET_HOST=user@backup-t470"

# Default target
all: switch
# NixOS rebuild commands
.PHONY: switch test boot build

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

# Default target
all: switch
# Local packages. Importable without flakes (nix-update): pkgs defaults to the locked nixpkgs.
{ pkgs ? import (fetchTree (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs.locked) { } }:
{
  tmux-harpoon = pkgs.callPackage ./tmux-harpoon.nix { };
  tmux-tilish = pkgs.callPackage ./tmux-tilish.nix { };
  jj-spr = pkgs.callPackage ./jj-spr.nix { };
  jj-stack = pkgs.callPackage ./jj-stack.nix { };
  jj-hooks = pkgs.callPackage ./jj-hooks.nix { };
  clipper = pkgs.callPackage ./clipper.nix { };
}

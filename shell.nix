{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Nix formatting and linting
    nixpkgs-fmt
    deadnix
    statix

    # Lua formatting
    stylua

    # Shell formatting and linting
    shellcheck
    shfmt

    # Multi-format formatter (Markdown, JSON, TOML, YAML, etc.)
    dprint

    # Markdown linting
    markdownlint-cli
  ];

  shellHook = ''
    echo "🚀 Development environment loaded"
    echo "Available formatters: nixpkgs-fmt, stylua, shfmt, dprint"
    echo "Run 'make format' to format all files"
    echo "Run 'make lint' to check all files"
  '';
}

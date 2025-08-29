{ pkgs ? import <nixpkgs> {} }:

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
    
    # JavaScript/TypeScript/YAML formatting
    nodePackages.prettier
    
    # TOML formatting
    taplo
    
    # Markdown linting
    markdownlint-cli
  ];
  
  shellHook = ''
    echo "🚀 Development environment loaded"
    echo "Available formatters: nixpkgs-fmt, stylua, shfmt, prettier"
    echo "Run 'make format' to format all files"
    echo "Run 'make lint' to check all files"
  '';
}
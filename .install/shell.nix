{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "chezmoi-bootstrap";

  packages = with pkgs; [
    # Required for chezmoi templates
    nushell
    bitwarden-cli

    # Task runner and development environment
    just
    devenv

    # Useful for initial setup
    git
    chezmoi
  ];

  shellHook = ''
    echo "🚀 Chezmoi bootstrap environment loaded"
    echo "   Nushell: $(nu --version)"
    echo "   Bitwarden CLI: $(bw --version)"
    echo "   Chezmoi: $(chezmoi --version)"
    echo "   Just: $(just --version)"
    echo "   Devenv: $(devenv version)"
    echo ""
    echo "You can now run: chezmoi init https://github.com/mariomarin/dotfiles.git"
  '';
}

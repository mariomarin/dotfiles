{ pkgs, lib, ... }:

{
  # Development environment for this repository
  # Includes formatters and linters for all languages used

  packages = with pkgs; [
    # Nix formatting and linting
    nixpkgs-fmt
    deadnix
    statix

    # Lua formatting
    stylua

    # Shell formatting and linting
    shellcheck
    shfmt

    # Multi-format formatting (JSON, YAML, Markdown, TOML)
    biome

    # Markdown linting
    markdownlint-cli
  ];

  # Git hooks - format only staged files on commit
  git-hooks = {
    hooks = {
      # Post-commit hook to run make (applies chezmoi changes)
      post-commit = {
        enable = true;
        name = "Apply changes with make";
        entry = "make";
        language = "system";
        pass_filenames = false;
        always_run = true;
        stages = [ "post-commit" ];
      };

      # Nix formatting
      nixpkgs-fmt.enable = true;

      # Lua formatting
      stylua.enable = true;

      # Shell formatting with specific settings
      shfmt = {
        enable = true;
        entry = lib.mkForce "shfmt -w -i 2 -ci -sr -kp";
      };

      # Shell linting
      shellcheck = {
        enable = true;
        excludes = [ ".envrc" ]; # .envrc uses direnv-specific functions
      };

      # Multi-format formatting with biome
      biome = {
        enable = true;
        name = "biome";
        entry = "biome format --write --no-errors-on-unmatched";
        files = "\\.(json|jsonc|md|yml|yaml|toml)$";
        language = "system";
        pass_filenames = true;
      };
    };
  };

  # Shell initialization
  enterShell = ''
    echo "🚀 Development environment loaded"
    echo "📝 Pre-commit hooks installed - will format staged files on commit"
    echo "Available formatters: nixpkgs-fmt, stylua, shfmt, biome"
    echo "Run 'make format' to format all files"
    echo "Run 'make lint' to check all files"
  '';
}

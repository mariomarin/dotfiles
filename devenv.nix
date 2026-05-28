{ pkgs, lib, inputs, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in

{
  # Development environment for this repository
  # Includes formatters and linters for all languages used

  # Enable dotenv support for loading .env file
  dotenv.enable = true;

  # Disable cachix auto-management (nix.conf managed by Determinate Systems)
  cachix.enable = false;

  packages = with pkgs; [
    # Nix formatting, linting, and LSP
    nixpkgs-fmt
    deadnix
    statix
    nil # Nix LSP

    # Lua formatting and LSP
    stylua
    lua-language-server

    # Shell formatting, linting, and LSP
    shellcheck
    shfmt
    bash-language-server

    # JSON LSP
    vscode-langservers-extracted # Includes JSON, HTML, CSS LSPs

    # YAML formatting and LSP
    yamlfmt
    yaml-language-server

    # TOML formatting and LSP
    taplo

    # Markdown linting and LSP
    rumdl
    marksman

    # Commit message linting
    commitizen

    # Task runner (needed by justfile-fmt hook)
    just

    # Nushell (needed by nushell-check and nushell-test hooks)
    nushell

    # Nushell linter and formatter (unstable for latest versions)
    pkgs-unstable.nu-lint
    pkgs-unstable.nufmt
  ];

  # Claude Code integration
  claude.code = {
    # Hooks to protect against dangerous commands
    hooks.PreToolUse.Bash = pkgs.writeShellScript "validate-bash-command" ''
      # Read JSON input from stdin
      INPUT=$(cat)

      # Extract command from JSON (using basic grep since jq might not be available)
      COMMAND=$(echo "$INPUT" | grep -o '"command":"[^"]*"' | cut -d'"' -f4)

      # Check for dangerous chezmoi commands
      if echo "$COMMAND" | grep -qE "chezmoi\s+purge"; then
        echo "⛔ BLOCKED: 'chezmoi purge' is destructive and will delete your entire chezmoi source directory."
        echo "This command has been blocked for your safety."
        echo ""
        echo "If you need to reset script state, use these SAFE alternatives:"
        echo "  chezmoi state delete-bucket --bucket=scriptState    # Reset run_once_ scripts"
        echo "  chezmoi state delete-bucket --bucket=entryState     # Reset run_onchange_ scripts"
        exit 1
      fi

      if echo "$COMMAND" | grep -qE "chezmoi\s+state\s+reset"; then
        echo "⛔ BLOCKED: 'chezmoi state reset' is destructive and will cause chezmoi to lose track of all managed files."
        echo "This command has been blocked for your safety."
        echo ""
        echo "Use these SAFE alternatives instead:"
        echo "  chezmoi state delete-bucket --bucket=scriptState    # Clear run_once_ script state"
        echo "  chezmoi state delete-bucket --bucket=entryState     # Clear run_onchange_ script state"
        exit 1
      fi

      # Block direct deletion of state files
      if echo "$COMMAND" | grep -qE "rm.*chezmoistate\.boltdb|rm.*\.chezmoidata\.db"; then
        echo "⛔ BLOCKED: Direct deletion of chezmoi state database files is dangerous."
        echo "This will cause chezmoi to lose track of all managed files."
        echo ""
        echo "Use 'chezmoi state delete-bucket' commands instead for safe state management."
        exit 1
      fi

      # Suggest just format for direct formatter calls
      if echo "$COMMAND" | grep -qE "^\s*(shfmt|nixpkgs-fmt|stylua|rumdl|yamlfmt|biome)\s"; then
        echo "💡 SUGGESTION: Use 'just format' instead of calling formatters directly."
        echo ""
        echo "This ensures consistent formatting across all files with proper excludes."
        echo ""
        echo "Available targets:"
        echo "  just format          # Format all files"
        echo "  just format-shell    # Format shell scripts (excludes zsh)"
        echo "  just format-nix      # Format Nix files"
        echo "  just format-lua      # Format Lua files"
        echo ""
        echo "Proceeding with direct formatter call..."
      fi

      # Suggest just jj-push for jj git push
      if echo "$COMMAND" | grep -qE "jj\s+git\s+push"; then
        echo "💡 SUGGESTION: Use 'just jj-push' to run pre-commit checks before pushing."
        echo ""
        echo "This ensures all commits pass validation before being pushed to remote."
        echo ""
        echo "Available targets:"
        echo "  just jj-check      # Check what would be pushed (dry-run)"
        echo "  just jj-push       # Check and push if all hooks pass"
        echo "  just jj-push-fast  # Skip checks and push immediately"
        echo ""
        echo "Proceeding with direct jj git push (no pre-commit checks)..."
      fi

      # Remind about tests for new/modified .nu scripts
      if echo "$COMMAND" | grep -qE "(Write|Edit).*\.nu['\"]?\s*\$"; then
        echo "💡 REMINDER: Did you add/update tests for this Nushell script?"
        echo ""
        echo "Test file location:"
        echo "  - For .scripts/*.nu → .scripts/tests/script-name.nu"
        echo "  - For .local/bin/*.nu → .local/bin/tests/script-name.nu"
        echo "  - For nix/*/*.nu → nix/*/tests/script-name.nu"
        echo ""
        echo "Run tests with: just test-nu"
        echo ""
      fi

      # Allow all other commands
      exit 0
    '';
  };

  # Git hooks - format only staged files on commit
  git-hooks = {
    hooks = {
      # Commit message linting
      commitizen = {
        enable = true;
        # Enforces conventional commits format:
        # type(scope): subject
        #
        # type: feat, fix, docs, style, refactor, test, chore
        # subject: max 50 chars, imperative mood, no period
      };

      # Post-commit hook to run just (applies chezmoi changes)
      # Just automatically loads .env.local via 'set dotenv-load'
      post-commit = {
        enable = true;
        name = "Apply changes with just";
        entry = lib.mkForce "just";
        language = "system";
        pass_filenames = false;
        always_run = true;
        stages = [ "post-commit" ];
      };

      # Nix formatting
      nixpkgs-fmt.enable = true;

      # Nix dead code detection
      deadnix = {
        enable = true;
        name = "deadnix";
        entry = "deadnix --fail";
        files = "\\.nix$";
        language = "system";
        pass_filenames = true;
      };

      # Nix linting and syntax checking (whole-repo for cross-file analysis)
      statix = {
        enable = true;
        name = "statix";
        entry = "statix check .";
        files = "\\.nix$";
        language = "system";
        pass_filenames = false;
      };

      # Lua formatting
      stylua.enable = true;

      # Shell formatting with specific settings
      shfmt = {
        enable = true;
        entry = lib.mkForce "shfmt -w -i 2 -ci -sr -kp";
        excludes = [
          ".*\\.zsh$" # Exclude zsh files
          ".*zshrc$"
          ".*zshenv$"
          "private_dot_config/zim/.*" # Exclude zim modules
        ];
      };

      # Shell linting
      shellcheck = {
        enable = true;
        excludes = [
          ".envrc" # .envrc uses direnv-specific functions
          ".*\\.zsh$" # Exclude zsh files
          ".*zshrc$"
          ".*zshenv$"
          "private_dot_config/zim/.*" # Exclude zim modules
        ];
      };

      # Nushell formatting
      nufmt = {
        enable = true;
        name = "nufmt";
        entry = "nufmt";
        files = "(\\.nu$|/executable_[^.]+$)";
        types_or = [ "text" ];
        excludes = [ "wsl-" "nushell/env\\.nu" ];
        language = "system";
        pass_filenames = true;
      };

      # Nushell validation (nu-check + nu-lint)
      nushell-check = {
        enable = true;
        name = "nushell-check";
        entry = "nu .scripts/nu-check.nu";
        files = "(\\.nu$|/executable_[^.]+$)";
        types_or = [ "text" ];
        excludes = [ "wsl-" "nushell/env\\.nu" ];
        language = "system";
        pass_filenames = true;
      };

      # Nushell tests (runs relevant tests for changed files)
      nushell-test = {
        enable = true;
        name = "nushell-test";
        entry = "nu .scripts/tests/run-for-files.nu";
        files = "\\.nu$";
        language = "system";
        pass_filenames = true;
      };

      # TOML formatting with taplo (exclude chezmoi templates)
      taplo = {
        enable = true;
        name = "taplo";
        entry = "taplo fmt";
        files = "\\.toml$";
        excludes = [ "chezmoiexternal" ];
        language = "system";
        pass_filenames = true;
      };

      # YAML formatting with yamlfmt
      yamlfmt = {
        enable = true;
        name = "yamlfmt";
        entry = "yamlfmt";
        files = "\\.(yml|yaml)$";
        excludes = [ "pre-commit-config" ];
        language = "system";
        pass_filenames = true;
      };

      # Markdown linting and formatting
      rumdl = {
        enable = true;
        name = "rumdl";
        entry = "rumdl fmt .";
        files = "\\.md$";
        language = "system";
        pass_filenames = false;
      };

      # Justfile formatting
      justfile-fmt = {
        enable = true;
        name = "justfile-fmt";
        entry = "just --fmt --unstable";
        files = "justfile$";
        language = "system";
        pass_filenames = false;
        always_run = false;
      };

      # LeftWM config validation (NixOS-only, requires leftwm binary)
      leftwm-check = {
        enable = true;
        name = "leftwm-check";
        entry = "sh -c '[ \"$(uname)\" = Linux ] || exit 0; command -v leftwm >/dev/null || exit 0; leftwm check'";
        files = "config\\.ron(\\.tmpl)?$";
        language = "system";
        pass_filenames = false;
        always_run = false;
      };

      # Kanata config validation (Linux-only, macOS kills kanata without Input Monitoring)
      kanata-check = {
        enable = true;
        name = "kanata-check";
        entry = "sh -c '[ \"$(uname)\" = Linux ] || exit 0; command -v kanata >/dev/null || exit 0; for f; do kanata --check --cfg \"$f\" || exit 1; done' --";
        files = "private_dot_config/kanata/(darwin|windows|laptop)\\.kbd$";
        language = "system";
        pass_filenames = true;
      };
    };
  };
}

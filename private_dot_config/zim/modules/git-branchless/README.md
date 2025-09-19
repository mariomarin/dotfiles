# git-branchless

Adds command completion for [git-branchless](https://github.com/arxanas/git-branchless).

## Prerequisites

This module requires git-branchless to be installed. You can install it with:

```sh
# Using cargo
cargo install git-branchless

# Or on NixOS
nix-env -iA nixpkgs.git-branchless
```

## Usage

The module provides completion for all git-branchless commands and their options:

- `git-branchless <TAB>` - Shows all available subcommands
- `git-branchless amend <TAB>` - Shows options for the amend command
- And so on for all other subcommands

## Features

- Complete subcommand suggestions with descriptions
- Context-aware option completion
- Integration with git completion for commit and branch references
- Support for all git-branchless commands including:
  - `amend`, `hide`, `init`, `move`, `next`, `prev`
  - `query`, `record`, `repair`, `restack`, `reword`
  - `smartlog`, `submit`, `switch`, `sync`, `test`
  - `undo`, `unhide`, `wrap`

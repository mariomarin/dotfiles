#!/usr/bin/env zsh
#
# Git Branchless completion module for Zim
#
# This module provides command completion for git-branchless
#

# Add the module's functions directory to fpath
# This allows the completion function to be found
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
fpath=(${0:h}/functions ${fpath})

# Check if git-branchless is installed
if (( ! ${+commands[git-branchless]} )); then
  return 1
fi

# The completion function will be autoloaded from functions/_git-branchless
# when the user first attempts completion on the git-branchless command
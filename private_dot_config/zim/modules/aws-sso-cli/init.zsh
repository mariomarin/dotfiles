# shellcheck shell=bash disable=SC2148,SC2168
#
# aws-sso-cli completions and helper functions module for Zim
#

# Return if requirements are not found.
command -v aws-sso > /dev/null 2>&1 || return 1

# Get the actual directory of this module
# Using POSIX-compatible method to get script directory
local module_dir
if [[ -n "${BASH_SOURCE[0]}" ]]; then
  module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  # Fallback for Zsh - this will be skipped by shfmt but work in Zsh
  module_dir="$(cd "$(dirname "$0")" && pwd)"
fi

# Initialize bashcompinit for AWS SSO completions
# AWS SSO uses bash-style completions, so we need bashcompinit
# This is safe to call multiple times - it only initializes once
autoload -Uz +X bashcompinit && bashcompinit

# Generate and cache completions
_generate_aws_sso_completions() {
  local aws_sso_path
  aws_sso_path="$(command -v aws-sso)"
  local completion_dir="${module_dir}/functions"
  local completions_file="${completion_dir}/_aws-sso-completions.zsh"

  # Create functions directory if it doesn't exist
  [[ -d "${completion_dir}" ]] || mkdir -p "${completion_dir}"

  # Regenerate completions if binary has changed (e.g., NixOS rebuild)
  if [[ ! -f "${completions_file}" ]] || [[ "${aws_sso_path}" -nt "${completions_file}" ]]; then
    # Generate completions and remove compdef lines (compinit hasn't run yet)
    # We'll manually register the completion later
    aws-sso setup completions --source 2> /dev/null | \
      grep -v '^compdef ' >| "${completions_file}" || return 1
  fi

  # Source the cached completions file (without compdef lines)
  # shellcheck disable=SC1090
  source "${completions_file}"

  # Manually register completion if compdef is available
  # (it will be after the completion module loads)
  if (( ${+functions[compdef]} )); then
    compdef __aws_sso_profile_complete aws-sso-profile
  fi
}

# Generate and load completions
_generate_aws_sso_completions
# Clean up the function
unset -f _generate_aws_sso_completions

#
# container-use completions module for Zim
#

# Return if requirements are not found.
command -v container-use > /dev/null 2>&1 || return 1

# Get the actual directory of this module
# Using POSIX-compatible method to get script directory
local module_dir
if [[ -n "${BASH_SOURCE[0]}" ]]; then
  module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  # Fallback for Zsh - this will be skipped by shfmt but work in Zsh
  module_dir="$(cd "$(dirname "$0")" && pwd)"
fi

# Add completions to fpath before generating them
fpath=("${module_dir}/functions" ${fpath})

# Generate completions if needed
_generate_container_use_completions() {
  local container_use_path
  container_use_path="$(command -v container-use)"
  local completion_dir="${module_dir}/functions"
  local container_use_completion="${completion_dir}/_container-use"
  local cu_completion="${completion_dir}/_cu"

  # Create functions directory if it doesn't exist
  [[ -d "${completion_dir}" ]] || mkdir -p "${completion_dir}"

  # Generate or update container-use completion
  if [[ ! -f "${container_use_completion}" ]] || [[ "${container_use_path}" -nt "${container_use_completion}" ]]; then
    container-use completion zsh >| "${container_use_completion}" 2> /dev/null || return 1
  fi

  # Generate or update cu completion
  if [[ ! -f "${cu_completion}" ]] || [[ "${container_use_path}" -nt "${cu_completion}" ]]; then
    container-use completion --command-name=cu zsh >| "${cu_completion}" 2> /dev/null || return 1
  fi
}

# Call the function
_generate_container_use_completions
# Clean up the function
unset -f _generate_container_use_completions

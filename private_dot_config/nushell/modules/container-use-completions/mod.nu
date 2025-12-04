# Container Use completions for Nushell

# Helper to get environment IDs
def _cu_envs [] {
    ^container-use list --quiet | lines
}

# Helper for shell types
def _cu_shells [] {
    ["bash" "zsh" "fish" "powershell" "nushell"]
}

# Completion for container-use command
export extern "container-use" [
    --help(-h)       # Display command help
    --version        # Show version information
    --debug          # Enable debug output
]

# Completion for cu (alias)
export extern "cu" [
    --help(-h)       # Display command help
    --version        # Show version information
    --debug          # Enable debug output
]

# Environment management
export extern "container-use list" [
    --no-trunc       # Prevent output truncation
    --quiet(-q)      # Show only environment IDs
]

export extern "container-use delete" [
    environment_id?: string@_cu_envs  # Environment ID to delete
    --all            # Delete all environments
]

export extern "container-use watch" []

# Environment inspection
export extern "container-use log" [
    environment_id: string@_cu_envs   # Environment ID to view logs
    --patch(-p)      # Display patch output with diffs
]

export extern "container-use diff" [
    environment_id: string@_cu_envs   # Environment ID to show diff
]

# Environment interaction
export extern "container-use checkout" [
    environment_id: string@_cu_envs   # Environment ID to checkout
    --branch(-b): string              # Specify branch name
]

export extern "container-use terminal" [
    environment_id: string@_cu_envs   # Environment ID to open terminal
]

# Code integration
export extern "container-use merge" [
    environment_id: string@_cu_envs   # Environment ID to merge
    --delete(-d)     # Remove environment after successful merge
]

export extern "container-use apply" [
    environment_id: string@_cu_envs   # Environment ID to apply changes
    --delete(-d)     # Remove environment after successful apply
]

# Configuration
export extern "container-use config" []

export extern "container-use config show" [
    environment_id?: string@_cu_envs  # Environment ID (optional)
]

export extern "container-use config import" [
    environment_id: string@_cu_envs   # Environment ID to import config from
]

export extern "container-use config base-image set" [
    image: string    # Docker image to set as base
]

# System commands
export extern "container-use version" []

export extern "container-use stdio" []

export extern "container-use completion" [
    shell: string@_cu_shells          # Shell type for completion generation
]

# Aliases for cu command
export extern "cu list" [
    --no-trunc       # Prevent output truncation
    --quiet(-q)      # Show only environment IDs
]

export extern "cu delete" [
    environment_id?: string@_cu_envs  # Environment ID to delete
    --all            # Delete all environments
]

export extern "cu watch" []

export extern "cu log" [
    environment_id: string@_cu_envs   # Environment ID to view logs
    --patch(-p)      # Display patch output with diffs
]

export extern "cu diff" [
    environment_id: string@_cu_envs   # Environment ID to show diff
]

export extern "cu checkout" [
    environment_id: string@_cu_envs   # Environment ID to checkout
    --branch(-b): string              # Specify branch name
]

export extern "cu terminal" [
    environment_id: string@_cu_envs   # Environment ID to open terminal
]

export extern "cu merge" [
    environment_id: string@_cu_envs   # Environment ID to merge
    --delete(-d)     # Remove environment after successful merge
]

export extern "cu apply" [
    environment_id: string@_cu_envs   # Environment ID to apply changes
    --delete(-d)     # Remove environment after successful apply
]

export extern "cu config" []

export extern "cu config show" [
    environment_id?: string@_cu_envs  # Environment ID (optional)
]

export extern "cu config import" [
    environment_id: string@_cu_envs   # Environment ID to import config from
]

export extern "cu config base-image set" [
    image: string    # Docker image to set as base
]

export extern "cu version" []

export extern "cu stdio" []

export extern "cu completion" [
    shell: string@_cu_shells          # Shell type for completion generation
]

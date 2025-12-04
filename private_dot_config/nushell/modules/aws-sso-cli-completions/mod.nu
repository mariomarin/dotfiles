# AWS SSO CLI completions for Nushell

# Helper to get profiles
def _aws_sso_profiles [] {
    try {
        ^aws-sso list --csv
        | from csv
        | get Profile?
        | default []
    } catch {
        []
    }
}

# Helper to get roles
def _aws_sso_roles [] {
    try {
        ^aws-sso list --csv
        | from csv
        | get RoleName?
        | default []
        | uniq
    } catch {
        []
    }
}

# Helper to get accounts
def _aws_sso_accounts [] {
    try {
        ^aws-sso list --csv
        | from csv
        | get AccountId?
        | default []
        | uniq
    } catch {
        []
    }
}

# Helper for log levels
def _log_levels [] {
    ["error" "warn" "info" "debug" "trace"]
}

# Helper for shells
def _shells [] {
    ["bash" "fish" "zsh" "zonsh" "powershell"]
}

# Helper for URL actions
def _url_actions [] {
    ["open" "print" "copy"]
}

# Main aws-sso command
export extern "aws-sso" [
    --help(-h)                # Show contextual help
    --browser(-b): string     # Override default browser
    --config: string          # Alternative config file
    --level(-L): string@_log_levels  # Log level
    --lines                   # Include file line numbers in logs
    --sso(-S): string         # Non-default AWS SSO instance
]

# cache - Refresh cached AWS info
export extern "aws-sso cache" [
    --no-config-check         # Disable automatic config updates
    --threads: int            # Parallel threads (default: 5)
]

# console - Generate AWS Console URL
export extern "aws-sso console" [
    --duration(-d): int       # Session duration in minutes
    --prompt(-P)              # Force interactive role selection
    --region(-r): string      # Set AWS_DEFAULT_REGION
    --arn(-a): string         # Role ARN to assume
    --account(-A): string@_aws_sso_accounts  # AWS Account ID
    --role(-R): string@_aws_sso_roles        # AWS role name
    --profile(-p): string@_aws_sso_profiles  # AWS profile name
    --url-action(-u): string@_url_actions    # URL handling method
    --sts-refresh             # Force STS token refresh
]

# credentials - Generate static credentials
export extern "aws-sso credentials" [
    --file(-f): string        # Output file path
    --append(-a)              # Append instead of overwrite
    --profile(-p): string@_aws_sso_profiles  # Profile to include
    --sts-refresh             # Force STS token refresh
]

# eval - Output shell export statements
export extern "aws-sso eval" [
    --arn(-a): string         # Role ARN to assume
    --account(-A): string@_aws_sso_accounts  # AWS Account ID
    --role(-R): string@_aws_sso_roles        # Role name
    --profile(-p): string@_aws_sso_profiles  # Profile name
    --clear(-c)               # Generate unset commands
    --no-region               # Omit AWS_DEFAULT_REGION
    --refresh                 # Refresh current credentials
]

# exec - Execute command with AWS credentials
export extern "aws-sso exec" [
    --arn(-a): string         # Role ARN to assume
    --account(-A): string@_aws_sso_accounts  # AWS Account ID
    --env(-e)                 # Use existing ENV vars
    --role(-R): string@_aws_sso_roles        # Role name
    --profile(-p): string@_aws_sso_profiles  # Profile name
    --no-region               # Omit AWS_DEFAULT_REGION
    --sts-refresh             # Force STS token refresh
    --ignore-env(-i)          # Override existing AWS_* vars
    command?: string          # Command to execute
    ...args: string           # Command arguments
]

# process - External credentials provider
export extern "aws-sso process" [
    --arn(-a): string         # Role ARN to assume
    --account(-A): string@_aws_sso_accounts  # AWS Account ID
    --role(-R): string@_aws_sso_roles        # Role name
    --profile(-p): string@_aws_sso_profiles  # Profile name
    --sts-refresh             # Force STS token refresh
]

# list - Display accessible AWS roles
export extern "aws-sso list" [
    --list-fields(-f)         # Display available field names
    --prefix: string          # Filter by field prefix
    --csv                     # Output in CSV format
    --sort(-s): string        # Sort by field name
    --reverse                 # Reverse sort order
]

# login - Authenticate via AWS Identity Center
export extern "aws-sso login" [
    --no-config-check         # Disable automatic config updates
    --url-action(-u): string@_url_actions  # URL handling method
    --sts-refresh             # Force STS token refresh
    --threads: int            # Parallel threads
]

# logout - Invalidate token and clear cache
export extern "aws-sso logout" []

# setup - Setup commands
export extern "aws-sso setup" []

# setup completions - Install shell auto-completion
export extern "aws-sso setup completions" [
    --source                  # Print completions for sourcing
    --install                 # Install completion scripts
    --uninstall               # Uninstall completion scripts
    --shell: string@_shells   # Override detected shell
    --shell-script: string    # Specify shell config file
]

# setup ecs - Configure ECS server
export extern "aws-sso setup ecs" []

# setup profiles - Generate named profiles in ~/.aws/config
export extern "aws-sso setup profiles" [
    --diff                    # Show changes without applying
    --print                   # Display profiles only
    --force                   # Write without confirmation
    --aws-config: string      # Override ~/.aws/config path
]

# setup wizard - Interactive configuration wizard
export extern "aws-sso setup wizard" [
    --advanced                # Prompt for additional options
]

# tags - Display roles with metadata tags
export extern "aws-sso tags" [
    --account: string@_aws_sso_accounts  # Filter by Account ID
    --role: string@_aws_sso_roles        # Filter by role name
]

# time - Print credential validity duration
export extern "aws-sso time" []

# Shell helper - assume role by profile name
export def "aws-sso-profile" [
    profile: string@_aws_sso_profiles  # Profile name to assume
    --sso(-S): string                  # SSO instance
] {
    if ($sso | is-empty) {
        ^aws-sso eval --profile $profile | str trim
    } else {
        ^aws-sso eval --sso $sso --profile $profile | str trim
    }
}

# Shell helper - clear AWS environment variables
export def "aws-sso-clear" [] {
    $env.AWS_ACCESS_KEY_ID = null
    $env.AWS_SECRET_ACCESS_KEY = null
    $env.AWS_SESSION_TOKEN = null
    $env.AWS_DEFAULT_REGION = null
    $env.AWS_SSO_ACCOUNT_ID = null
    $env.AWS_SSO_ROLE_NAME = null
    $env.AWS_SSO_ROLE_ARN = null
    $env.AWS_SSO_SESSION_EXPIRATION = null
    $env.AWS_SSO_DEFAULT_REGION = null
    $env.AWS_SSO_PROFILE = null
    $env.AWS_SSO = null
}

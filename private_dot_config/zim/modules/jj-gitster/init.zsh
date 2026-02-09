# jj-gitster - Extends gitster prompt with jj information
# Shows jj bookmark info before git status when in jj repository
# This is a Zsh module - no shebang needed as it's sourced, not executed

# This module requires jj-info to be loaded first
if (( ! ${+functions[jj_prompt_info]} )); then
    print -P "%F{red}jj-gitster:%f jj-info module must be loaded first"
    return 1
fi

# Wrapper around gitster's precmd to add jj info
prompt_jj_gitster_precmd() {
    # Update jj info
    jj_prompt_info

    # Call original gitster setup if it exists
    (( ${+functions[prompt_gitster_setup]} )) && prompt_gitster_setup
}

# Setup function for prompt
prompt_jj_gitster_setup() {
    # Ensure prompt function is available
    autoload -Uz promptinit && promptinit

    # Load gitster first
    prompt gitster

    # Replace gitster's precmd with our wrapper
    if (( ${+functions[prompt_gitster_precmd]} )); then
        autoload -Uz add-zsh-hook
        add-zsh-hook -d precmd prompt_gitster_precmd
        add-zsh-hook precmd prompt_jj_gitster_precmd
    fi

    # Modify PROMPT to include jj_info
    # Insert jj info after prompt_pwd, before git_info
    # gitster PROMPT looks like: ${prompt_pwd} ${git_info} ${editor_info}
    PROMPT='${prompt_pwd}${jj_info_prompt:+ ${jj_info_prompt}} ${git_info}${editor_info}'
}

# Make this available as a prompt theme
prompt_jj_gitster_setup "$@"

# jj-info - Jujutsu repository information for zim prompts
# Provides jj_prompt_info function similar to git-info
# This is a Zsh module - no shebang needed as it's sourced, not executed

# Check if we're in a jj repository
_jj_in_repo() {
    jj workspace root &>/dev/null
}

# Get the closest bookmark (local or remote)
_jj_closest_bookmark() {
    jj log --no-graph --limit 1 --color never \
        -r "coalesce(
            heads(::@ & bookmarks()),
            heads(::@ & remote_bookmarks()),
            trunk()
        )" -T "separate(' ', bookmarks)" 2>/dev/null | head -1
}

# Get distance from bookmark (how many commits after)
_jj_bookmark_distance() {
    local bookmark=$1
    [[ -z "$bookmark" ]] && return

    jj log --no-graph --color never \
        -r "$bookmark..@ & (~empty() | merges())" \
        -T '"n"' 2>/dev/null | wc -c | tr -d ' '
}

# Main prompt info function
# Sets jj_info_prompt with bookmark and distance
jj_prompt_info() {
    # Only proceed if jj command exists
    (( ! ${+commands[jj]} )) && return

    # Only proceed if in jj repository
    _jj_in_repo || return

    local bookmark distance
    bookmark=$(_jj_closest_bookmark)

    # If no bookmark found, just show [jj]
    if [[ -z "$bookmark" ]]; then
        jj_info_prompt="%F{cyan}[jj]%f"
        return
    fi

    distance=$(_jj_bookmark_distance "$bookmark")

    # Build prompt: bookmark›distance or just bookmark
    jj_info_prompt="%F{green}${bookmark}%f"

    if [[ "$distance" -gt 0 ]]; then
        jj_info_prompt+="%F{yellow}›${distance}%f"
    fi
}

# Async version using zsh-async (if available)
# This prevents the prompt from blocking on slow jj commands
if (( ${+functions[async_init]} )); then
    typeset -g _jj_info_prompt=""
    typeset -g _jj_info_workspace=""

    # Async worker function
    _jj_info_async_worker() {
        local workspace=$1
        local bookmark distance

        # Run jj commands
        bookmark=$(jj log --repository "$workspace" --no-graph --limit 1 --color never \
            -r "coalesce(
                heads(::@ & bookmarks()),
                heads(::@ & remote_bookmarks()),
                trunk()
            )" -T "separate(' ', bookmarks)" 2>/dev/null | head -1)

        if [[ -z "$bookmark" ]]; then
            echo "[jj]"
            return
        fi

        distance=$(jj log --repository "$workspace" --no-graph --color never \
            -r "$bookmark..@ & (~empty() | merges())" \
            -T '"n"' 2>/dev/null | wc -c | tr -d ' ')

        if [[ "$distance" -gt 0 ]]; then
            echo "${bookmark}›${distance}"
        else
            echo "${bookmark}"
        fi
    }

    # Async callback
    _jj_info_async_callback() {
        local job_name=$1 exit_code=$2 output=$3
        if [[ $exit_code == 0 ]]; then
            _jj_info_prompt=$output
        else
            _jj_info_prompt=""
        fi

        # Trigger prompt redraw if using a prompt that supports it
        # This works with gitster and other zim prompts
        zle && zle reset-prompt
    }

    # Initialize async worker
    async_init
    async_stop_worker _jj_info_worker 2>/dev/null
    async_start_worker _jj_info_worker
    async_unregister_callback _jj_info_worker 2>/dev/null
    async_register_callback _jj_info_worker _jj_info_async_callback

    # Async version of jj_prompt_info
    jj_prompt_info() {
        (( ! ${+commands[jj]} )) && return

        local workspace
        workspace=$(jj workspace root 2>/dev/null) || return

        # Track workspace changes
        if [[ $_jj_info_workspace != "$workspace" ]]; then
            _jj_info_prompt=""
            _jj_info_workspace="$workspace"
        fi

        # Request async update
        async_job _jj_info_worker _jj_info_async_worker "$workspace"

        # Return cached value (colored)
        if [[ -n "$_jj_info_prompt" ]]; then
            if [[ "$_jj_info_prompt" == "[jj]" ]]; then
                jj_info_prompt="%F{cyan}${_jj_info_prompt}%f"
            elif [[ "$_jj_info_prompt" == *"›"* ]]; then
                local bm=${_jj_info_prompt%%›*}
                local dist=${_jj_info_prompt##*›}
                jj_info_prompt="%F{green}${bm}%f%F{yellow}›${dist}%f"
            else
                jj_info_prompt="%F{green}${_jj_info_prompt}%f"
            fi
        fi
    }
fi

# Provide simple variable for inclusion in prompts
typeset -g jj_info_prompt=""

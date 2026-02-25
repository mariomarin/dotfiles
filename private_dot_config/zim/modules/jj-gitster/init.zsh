# jj-gitster - Extends gitster prompt with jj information
# Prefers jj status over git status when in jj repository
# This is a Zsh module - no shebang needed as it's sourced, not executed

# This module requires jj-info to be loaded first
if (( ! ${+functions[jj_prompt_info]} )); then
    print -P "%F{red}jj-gitster:%f jj-info module must be loaded first"
    return 1
fi

# Source gitster theme
source ${ZIM_HOME}/modules/gitster/gitster.zsh-theme

# Add jj info to precmd (after git-info)
autoload -Uz add-zsh-hook && add-zsh-hook precmd jj_prompt_info

# Helper function to show jj or git info (prefers jj)
_jj_or_git_info() {
    if [[ -n "$jj_info_prompt" ]]; then
        echo " ${jj_info_prompt}"
    else
        echo "${(e)git_info[prompt]}"
    fi
}

# Modify PS1 to prefer jj over git using helper function
PS1='%B%(?:%F{green}:%F{red})%{%G➜%} %F{white}$(prompt-pwd)$(_jj_or_git_info)%f%b '

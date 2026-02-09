# jj-gitster - Extends gitster prompt with jj information
# Shows jj bookmark info before git status when in jj repository
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

# Modify PS1 to include jj_info_prompt
# Original: %B%(?:%F{green}:%F{red})%{%G➜%} %F{white}$(prompt-pwd)${(e)git_info[prompt]}%f%b
# Modified: Add ${jj_info_prompt:+ ${jj_info_prompt}} after prompt-pwd
PS1='%B%(?:%F{green}:%F{red})%{%G➜%} %F{white}$(prompt-pwd)${jj_info_prompt:+ ${jj_info_prompt}}${(e)git_info[prompt]}%f%b '

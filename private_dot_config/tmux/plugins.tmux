# list of plugins and settings
set-environment -g TMUX_PLUGIN_MANAGER_PATH "${XDG_DATA_HOME}/tmux/plugins"

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# artic theme
set -g @plugin 'arcticicestudio/nord-tmux'

# restore vim and nvim sessions as well
set -g @plugin 'tmux-plugins/tmux-resurrect'
# for vim
set -g @resurrect-strategy-vim 'session'
set -g @resurrect-processes '"vim->vim +SLoad"'
# for neovim
set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-processes '"nvim->nvim +SLoad"'

set -g @resurrect-capture-pane-contents 'on'

# Automatic restore
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'
set -g @continuum-boot 'on'

# copy/pasting tmux like vimium/vimperator 
set -g @plugin 'fcsonline/tmux-thumbs'
# Choose in which direction you want to assign hints. Useful to get shorter
# hints closer to the cursor.
set -g @thumbs-reverse 'on'
set -g @thumbs-command 'echo -n {} | xclip -in -selection clipboard && tmux display-message \"Copied {}\"'
set -g @thumbs-upcase-command 'xdg-open {} && tmux display-message "Opened {}"'
set -g @thumbs-regexp-1 '[a-z0-9]+-[^ ]+'

# i3wm like navigation with TAB key
set -g @plugin 'farzadmf/tmux-tilish'
set -g @tilish-dmenu 'on'
set -g @tilish-new_pane '"'

# Seamless tmux/vim navigation (over SSH too!) 
set -g @plugin 'sunaku/tmux-navigate'
# enable tilish bind keys for tmux-navigate
# <M-[hjkl]>
set -g @tilish-navigate 'on'

# Use fzf to manage your tmux work environment! 
# To launch tmux-fzf, press prefix + F (Shift+F).
set -g @plugin 'sainnhe/tmux-fzf'

# Search your tmux scrollback buffer using fzf 
# To use tmux-fuzzback, start it in a tmux session by typing prefix + ?
set -g @plugin 'roosta/tmux-fuzzback'

# quickly select, copy/insert text without a mouse
set -g @plugin 'laktak/extrakto'
# press tmux prefix + tab to start extrakto
set -g @extrakto_popup_size '50%,60%'
# Whether the tmux split will be a:auto, p:popup, v:vertical or h:horizontal
set -g @extrakto_split_direction 'a'

# don't exit from tmux when closing a session
set -g detach-on-destroy off
# skip "kill-pane 1? (y/n)" prompt
bind-key x kill-pane 

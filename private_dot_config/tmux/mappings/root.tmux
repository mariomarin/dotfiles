bind-key -T prefix C-g split-window \
  "$SHELL --login -i -c 'navi --print | head -n 1 | tmux load-buffer -b tmp - ; tmux paste-buffer -p -t {last} -b tmp -d'"

bind-key "T" run-shell "sesh connect \"$(
	sesh list --icons | fzf-tmux -p 80%,70% \
		--no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
		--header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
		--bind 'tab:down,btab:up' \
		--bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
		--bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
		--bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
		--bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
		--bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
		--bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
		--preview-window 'right:55%' \
		--preview 'sesh preview {}'
)\""

bind -N "last-session (via sesh) " L run-shell "sesh last"

# Reload tmux configuration (override tmux-tilish default)
bind-key -n M-S-c source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

# Additional C-M-* bindings for kanata =+key (via extended-keys)
# These complement tmux-tilish's existing C-M-* bindings
# Note: tilish already provides C-M-s/v/t/n/0-9/hjkl, but not Shift variants

# Shift layout variants: =+S/V (C-M-S-s/v)
bind-key -n C-M-S-s select-layout even-vertical \; select-layout -E
bind-key -n C-M-S-v select-layout even-horizontal \; select-layout -E

# Refresh layout: =+r (C-M-r)
bind-key -n C-M-r select-layout -E

# Detach: =+E (C-M-S-e) and reload: =+C (C-M-S-c)
bind-key -n C-M-S-e detach-client
bind-key -n C-M-S-c source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

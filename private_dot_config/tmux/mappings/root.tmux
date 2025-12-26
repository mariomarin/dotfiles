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

# ── Extended-keys C-M-* overrides for tilish ──────────────────────────
# Tilish's @tilish-prefix creates a key table expecting two keystrokes (C-M, then key).
# With extended-keys + CSI u, Alacritty sends C-M-1 as a single chord, bypassing the table.
# These bindings override tilish's simple commands with upsert logic (create if not exists).

# Shift layout variants: =+S/V (C-M-S-s/v)
bind-key -n C-M-S-s select-layout even-vertical \; select-layout -E
bind-key -n C-M-S-v select-layout even-horizontal \; select-layout -E

# Refresh layout: =+r (C-M-r)
bind-key -n C-M-r select-layout -E

# Detach: =+E (C-M-S-e) and reload: =+C (C-M-S-c)
bind-key -n C-M-S-e detach-client
bind-key -n C-M-S-c source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

# Select window with upsert (create if not exists)
# Override tilish's simple select-window with fallback logic
bind-key -n C-M-0 if-shell "tmux select-window -t :0" '' "new-window -t :0"
bind-key -n C-M-1 if-shell "tmux select-window -t :1" '' "new-window -t :1"
bind-key -n C-M-2 if-shell "tmux select-window -t :2" '' "new-window -t :2"
bind-key -n C-M-3 if-shell "tmux select-window -t :3" '' "new-window -t :3"
bind-key -n C-M-4 if-shell "tmux select-window -t :4" '' "new-window -t :4"
bind-key -n C-M-5 if-shell "tmux select-window -t :5" '' "new-window -t :5"
bind-key -n C-M-6 if-shell "tmux select-window -t :6" '' "new-window -t :6"
bind-key -n C-M-7 if-shell "tmux select-window -t :7" '' "new-window -t :7"
bind-key -n C-M-8 if-shell "tmux select-window -t :8" '' "new-window -t :8"
bind-key -n C-M-9 if-shell "tmux select-window -t :9" '' "new-window -t :9"

# Move pane to window with upsert (create if not exists)
# Override tilish's simple join-pane with fallback logic
%hidden MOVE_PANE='n=$1; tmux join-pane -t :$n 2>/dev/null || { tmux new-window -dt :$n; tmux join-pane -t :$n; tmux select-pane -t top-left; tmux kill-pane; }; tmux select-layout; tmux select-layout -E'
bind-key -n C-M-S-0 run-shell "sh -c '$MOVE_PANE' -- 0"
bind-key -n C-M-S-1 run-shell "sh -c '$MOVE_PANE' -- 1"
bind-key -n C-M-S-2 run-shell "sh -c '$MOVE_PANE' -- 2"
bind-key -n C-M-S-3 run-shell "sh -c '$MOVE_PANE' -- 3"
bind-key -n C-M-S-4 run-shell "sh -c '$MOVE_PANE' -- 4"
bind-key -n C-M-S-5 run-shell "sh -c '$MOVE_PANE' -- 5"
bind-key -n C-M-S-6 run-shell "sh -c '$MOVE_PANE' -- 6"
bind-key -n C-M-S-7 run-shell "sh -c '$MOVE_PANE' -- 7"
bind-key -n C-M-S-8 run-shell "sh -c '$MOVE_PANE' -- 8"
bind-key -n C-M-S-9 run-shell "sh -c '$MOVE_PANE' -- 9"

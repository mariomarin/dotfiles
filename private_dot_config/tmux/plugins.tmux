# ── Plugin declarations (TPM) ─────────────────────────────────────────────────
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'Morantron/tmux-fingers'
set -g @plugin 'farzadmf/tmux-tilish'
set -g @plugin 'Chaitanyabsprip/tmux-harpoon'
set -g @plugin 'roosta/tmux-fuzzback'
set -g @plugin 'niksingh710/minimal-tmux-status'

# ── Plugin settings ───────────────────────────────────────────────────────────

# minimal-tmux-status theme
set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
set -g @minimal-tmux-bg "#E65050"

# tmux-resurrect
set -g @resurrect-strategy-vim 'session'
set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-processes '"vim->vim +SLoad" "nvim->nvim"'
set -g @resurrect-capture-pane-contents 'on'

# tmux-continuum
set -g @continuum-restore 'on'
set -g @continuum-boot 'on'
set -g @continuum-boot-options 'ghostty'
set -g @continuum-systemd-start-cmd 'start-server'

# tmux-yank: copy to system clipboard and exit copy mode
set -g @yank_action 'copy-pipe-and-cancel'
set -g @yank_selection 'clipboard'
set -g @yank_selection_mouse 'clipboard'
set -g @yank_with_mouse 'on'

# tmux-fingers: prefix + Space for hints, prefix + j for jump mode (moves the
# copy-mode cursor to a match, replacing tmux-jump). Default F/J bindings are
# off. Binary comes from chezmoi (~/.local/bin), so skip the install wizard.
set -g @fingers-skip-wizard 1
set -g @fingers-enable-bindings 0
bind Space run -b "#{@fingers-cli} start #{pane_id}"
bind j run -b "#{@fingers-cli} start #{pane_id} --mode jump"
# Actions read the match on stdin: "$t" is never re-parsed by the shell, and
# ## escapes # so display-message cannot expand formats or #(commands).
# Hint: copy via OSC52 (set-buffer -w) and clip (best-effort, over SSH too)
set -g @fingers-main-action 't=$(cat); tmux set-buffer -w -- "$t"; printf %s "$t" | clip 2>/dev/null; tmux display-message "Copied: $(printf %s "$t" | sed "s/#/##/g")"'
# Shift+hint: open via peek, no clipboard side effect
set -g @fingers-shift-action 't=$(cat); tmux set-buffer -- "$t"; peek "$t"; tmux display-message "Opening: $(printf %s "$t" | sed "s/#/##/g")"'
# Ctrl+hint: paste into the pane (fingers' default shift behaviour)
set -g @fingers-ctrl-action ':paste:'

# tmux-tilish (direct M-key bindings, i3wm-style)
set -g @tilish-navigator 'on'
set -g @tilish-dmenu 'on'
set -g @tilish-new_pane '"'
set -g @tilish-smart-splits 'on'
set -g @tilish-smart-splits-dirs '= + _ -'
set -g @tilish-smart-splits-dirs-large ""

# tmux-harpoon
# append1/2 suppress the default C-h (list) and C-S-h (add) bindings, so set explicitly
set -g @harpoon_key_append1 'C-S-a'
set -g @harpoon_key_append2 'M-a'
bind-key -n M-b   run-shell "~/.local/share/tmux/plugins/tmux-harpoon/harpoon -l"
bind-key -n C-S-h run-shell "~/.local/share/tmux/plugins/tmux-harpoon/harpoon -a"

# ── General settings ──────────────────────────────────────────────────────────

# For sesh: don't exit tmux when closing a session (switch to another)
set -g detach-on-destroy off

# Skip "kill-pane 1? (y/n)" prompt
bind-key x kill-pane

# Last window: prefix + Tab
bind-key Tab last-window

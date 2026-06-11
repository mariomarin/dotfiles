# ── Plugin declarations (TPM) ─────────────────────────────────────────────────
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'fcsonline/tmux-thumbs'
set -g @plugin 'farzadmf/tmux-tilish'
set -g @plugin 'Chaitanyabsprip/tmux-harpoon'
set -g @plugin 'schasse/tmux-jump'
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

# tmux-thumbs (prefix + F to activate)
set -g @thumbs-key Space
# Clipboard: OSC52 via set-buffer -w (primary), clip (best-effort, explicit path)
# Note: {} interpolation is not fully shell-safe for all inputs (embedded quotes, $(...))
set -g @thumbs-command 'tmux set-buffer -w -- "{}"; echo -n "{}" | clip 2>/dev/null; tmux display-message "Copied: {}"'
# Open: no clipboard side-effect
set -g @thumbs-upcase-command 'tmux set-buffer -- "{}"; peek "{}"; tmux display-message "Opening: {}"'

# tmux-jump (EasyMotion for copy-mode, prefix + j to activate)
set -g @jump-key 'j'

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

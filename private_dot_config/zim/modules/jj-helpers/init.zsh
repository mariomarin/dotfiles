# Jujutsu (jj) Helper Module for Zimfw
# Aliases only — all logic lives in ~/.local/bin/j (cross-shell Nu script)

(( ${+commands[jj]} )) || return 0

# Bookmark (b)
alias jb='jj bookmark'
alias jbc='jj bookmark create'
alias jbd='jj bookmark delete'
alias jbl='jj bookmark list'
alias jbm='jj bookmark move'
alias jbset='jj bookmark set'
alias jbtrack='jj bookmark track'

# Change (c)
alias jc='jj commit'
alias jd='jj describe'
alias jn='jj new'
alias je='jj edit'
alias jsq='jj squash'
alias jsqi='jj squash -i'
alias jsqf='jj squash --from'

# Diff (d)
alias jdiff='jj diff'
alias jde='jj diffedit'
alias jst='jj status'

# Log (l)
alias jl='jj log'
alias jlg='jj log --graph'
alias jsl='jj log -r "all()" --limit 20'

# Navigation (n)
alias jprev='jj prev'
alias jnext='jj next'

# Rebase (r)
alias jrb='jj rebase'
alias jrbi='jj rebase -d'
alias jrbs='jj rebase -s'
alias jrbr='jj rebase -r'

# Insert (i)
alias jins='jj new --insert-after'
alias jinb='jj new --insert-before'

# Abandon/hide (a)
alias jab='jj abandon'
alias junhide='jj restore'

# Operation log (o)
alias jop='jj op'
alias joplog='jj op log'
alias jundo='jj op undo'
alias jredo='jj op restore'

# Git operations — direct jj aliases
alias jgf='jj git fetch --tracked'

# j subcommand aliases (all logic in ~/.local/bin/j)
alias jsync='j sync'
alias jland='j land'
alias jpr='j pr'
alias jmove='j move'
alias jpush='j push'
alias jpush-main='j push-main'
alias jgp='j gp'
alias jspr='j spr'
alias jspra='j spr --all'
alias jjco='j co'
alias jclean='j clean'
alias jjhelp='j help'

alias jjst='jj status && echo && jj log -r "ancestors(@, 5)"'

[[ -f "${0:h}/local.zsh" ]] && source "${0:h}/local.zsh"

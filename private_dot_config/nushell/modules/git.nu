# Git aliases module for nushell
# Port of zim git module with 'g' prefix

# Log formats
const git_log_fuller_format = '%C(bold yellow)commit %H%C(auto)%d%n%C(bold)Author: %C(blue)%an <%ae> %C(cyan)%ai (%ar)%n%C(bold)Commit: %C(blue)%cn <%ce> %C(cyan)%ci (%cr)%C(reset)%n%+B'
const git_log_oneline_format = '%C(bold yellow)%h%C(reset) %s%C(auto)%d%C(reset)'
const git_log_oneline_medium_format = '%C(bold yellow)%h%C(reset) %<(50,trunc)%s %C(bold blue)%an %C(cyan)%as (%ar)%C(auto)%d%C(reset)'

# Git
export alias g = git

# Branch (gb)
export alias gb = git branch
export alias gbc = git checkout -b
export alias gbd = git checkout --detach
export alias gbl = git branch --list -vv
export alias gbL = git branch --list -vv --all
export alias gbn = git branch --no-contains
export alias gbm = git branch --move
export alias gbM = git branch --move --force
export alias gbR = git branch --force
export alias gbs = git show-branch
export alias gbS = git show-branch --all
export alias gbu = git branch --unset-upstream

# Commit (gc)
export alias gc = git commit --verbose
export alias gca = git commit --verbose --all
export alias gcA = git commit --verbose --patch
export alias gcm = git commit --message
export alias gco = git checkout
export alias gcO = git checkout --patch
export alias gcf = git commit --amend --reuse-message HEAD
export alias gcF = git commit --verbose --amend
export alias gcp = git cherry-pick
export alias gcP = git cherry-pick --no-commit
export alias gcr = git revert
export alias gcR = git reset "HEAD^"
export alias gcs = git show --pretty=format:$git_log_fuller_format
export alias gcS = git commit --verbose -S
export alias gcu = git commit --fixup
export alias gcU = git commit --squash
export alias gcv = git verify-commit

# Conflict (gC)
export def gCl [] { git diff --name-only --diff-filter=U }
export def gCa [] { git add ...(gCl) }
export def gCe [] { git mergetool ...(gCl) }
export alias gCo = git checkout --ours --
export def gCO [] { gCo ...(gCl) }
export alias gCt = git checkout --theirs --
export def gCT [] { gCt ...(gCl) }

# Data (gd)
export alias gd = git ls-files
export alias gdc = git ls-files --cached
export alias gdx = git ls-files --deleted
export alias gdm = git ls-files --modified
export alias gdu = git ls-files --other --exclude-standard
export alias gdk = git ls-files --killed
export def gdi [] { git status --porcelain --ignored=matching | lines | parse "{status} {file}" | where status == "!!" | get file }
export alias gdI = git ls-files --ignored --exclude-per-directory=.gitignore --cached

# Fetch (gf)
export alias gf = git fetch
export alias gfa = git fetch --all
export alias gfp = git fetch --all --prune
export alias gfc = git clone
export alias gfm = git pull --no-rebase
export alias gfr = git pull --rebase
export alias gfu = git pull --ff-only --all --prune

# Grep (gg)
export alias gg = git grep
export alias ggi = git grep --ignore-case
export alias ggl = git grep --files-with-matches
export alias ggL = git grep --files-without-match
export alias ggv = git grep --invert-match
export alias ggw = git grep --word-regexp

# Help (gh)
export alias gh = git help
export alias ghw = git help --web

# Index (gi)
export alias gia = git add --verbose
export alias giA = git add --patch
export alias giu = git add --verbose --update
export alias giU = git add --verbose --all
export alias gid = git diff --no-ext-diff --cached
export alias giD = git diff --no-ext-diff --cached --word-diff
export alias gir = git reset
export alias giR = git reset --patch
export alias gix = git rm --cached -r
export alias giX = git rm --cached -rf

# Log (gl)
export alias gl = git log --date-order --pretty=format:$git_log_fuller_format
export alias gls = git log --date-order --stat --pretty=format:$git_log_fuller_format
export alias gld = git log --date-order --stat --patch --pretty=format:$git_log_fuller_format
export alias glf = git log --date-order --stat --patch --follow --pretty=format:$git_log_fuller_format
export alias glo = git log --date-order --pretty=format:$git_log_oneline_format
export alias glO = git log --date-order --pretty=format:$git_log_oneline_medium_format
export alias glg = git log --date-order --graph --pretty=format:$git_log_oneline_format
export alias glG = git log --date-order --graph --pretty=format:$git_log_oneline_medium_format
export alias glv = git log --date-order --show-signature --pretty=format:$git_log_fuller_format
export alias glc = git shortlog --summary --numbered
export alias glr = git reflog

# Merge (gm)
export alias gm = git merge
export alias gma = git merge --abort
export alias gmc = git merge --continue
export alias gmC = git merge --no-commit
export alias gmF = git merge --no-ff
export alias gms = git merge --squash
export alias gmS = git merge -S
export alias gmv = git merge --verify-signatures
export alias gmt = git mergetool

# Push (gp)
export alias gp = git push
export alias gpf = git push --force-with-lease
export alias gpF = git push --force
export alias gpa = git push --all
export alias gpA = git push --all && git push --tags --no-verify
export alias gpt = git push --tags
export def gpc [] { git push --set-upstream origin (git rev-parse --abbrev-ref HEAD) }
export def gpp [] {
    let branch = (git rev-parse --abbrev-ref HEAD)
    git pull origin $branch
    git push origin $branch
}

# Rebase (gr)
export alias gr = git rebase
export alias gra = git rebase --abort
export alias grc = git rebase --continue
export alias gri = git rebase --interactive --autosquash
export alias grs = git rebase --skip
export alias grS = git rebase --exec "git commit --amend --no-edit --no-verify -S"

# Remote (gR)
export alias gR = git remote
export alias gRl = git remote --verbose
export alias gRa = git remote add
export alias gRx = git remote rm
export alias gRm = git remote rename
export alias gRu = git remote update
export alias gRp = git remote prune
export alias gRs = git remote show
export alias gRS = git remote set-url

# Stash (gs)
export alias gs = git stash
export alias gsa = git stash apply
export alias gsx = git stash drop
export alias gsl = git stash list
export alias gsd = git stash show --patch --stat
export alias gsp = git stash pop
export alias gss = git stash save --include-untracked
export alias gsS = git stash save --patch --no-keep-index
export alias gsw = git stash save --include-untracked --keep-index
export alias gsi = git stash push --staged
export alias gsu = git stash show --patch | git apply --reverse

# Submodule (gS)
export alias gS = git submodule
export alias gSa = git submodule add
export alias gSf = git submodule foreach
export alias gSi = git submodule init
export alias gSI = git submodule update --init --recursive
export alias gSl = git submodule status
export alias gSs = git submodule sync
export alias gSu = git submodule update --remote

# Tag (gt)
export alias gt = git tag
export alias gtl = git tag --list --sort=-committerdate
export alias gts = git tag --sign
export alias gtv = git verify-tag
export alias gtx = git tag --delete

# Main working tree (gw)
export alias gws = git status --short --branch
export alias gwS = git status
export alias gwd = git diff --no-ext-diff
export alias gwD = git diff --no-ext-diff --word-diff
export alias gwr = git reset --soft
export alias gwR = git reset --hard
export alias gwc = git clean --dry-run
export alias gwC = git clean -d --force
export alias gwm = git mv
export alias gwM = git mv -f
export alias gwx = git rm -r
export alias gwX = git rm -rf

# Working trees (gW)
export alias gW = git worktree
export alias gWa = git worktree add
export alias gWl = git worktree list
export alias gWm = git worktree move
export alias gWp = git worktree prune
export alias gWx = git worktree remove
export alias gWX = git worktree remove --force

# Switch (gy)
export alias gy = git switch
export alias gyc = git switch --create
export alias gyd = git switch --detach

# Misc
export def "g.." [] { cd (git rev-parse --show-toplevel | str trim) }
export def git-root [] { git rev-parse --show-toplevel | str trim }

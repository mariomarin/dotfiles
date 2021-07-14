zimfw() { source /home/mario/.zim/zimfw.zsh "${@}" }
fpath=(/home/mario/.zim/modules/git/functions /home/mario/.zim/modules/utility/functions /home/mario/.zim/modules/pacman/functions /home/mario/.zim/modules/git-info/functions ${fpath})
autoload -Uz git-alias-lookup git-branch-current git-branch-delete-interactive git-dir git-ignore-add git-root git-stash-clear-interactive git-stash-recover git-submodule-move git-submodule-remove mkcd mkpw coalesce git-action git-info
source /home/mario/.config/zim/modules/environment/init.zsh
source /home/mario/.config/zim/modules/git/init.zsh
source /home/mario/.config/zim/modules/input/init.zsh
source /home/mario/.config/zim/modules/termtitle/init.zsh
source /home/mario/.config/zim/modules/utility/init.zsh
source /home/mario/.config/zim/modules/exa/init.zsh
source /home/mario/.config/zim/modules/fzf/init.zsh
source /home/mario/.config/zim/modules/pacman/init.zsh
source /home/mario/.config/zim/modules/kube-ps1/kube-ps1.sh
source /home/mario/.config/zim/modules/gitster/gitster.zsh-theme
source /home/mario/.config/zim/modules/zsh-completions/zsh-completions.plugin.zsh
source /home/mario/.config/zim/modules/completion/init.zsh
source /home/mario/.config/zim/modules/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/mario/.config/zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/mario/.config/zim/modules/zsh-history-substring-search/zsh-history-substring-search.zsh
source /home/mario/.config/zim/modules/forgit/forgit.plugin.zsh

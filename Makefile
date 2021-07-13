all: install diff

init:
	chezmoi init "${CHEZMOI_REPO:-git@github.com:mariomarin/dotfiles.git}" --apply

diff:
	chezmoi source pull -- --rebase && chezmoi diff

install:
	curl -sfL https://git.io/chezmoi | sh

update-third-party: update-asdf-vm update-zimfw update-spacevim update-tpm update-dein

update-doom:
	curl -s -L -o /tmp/doom.tar.gz https://github.com/hlissner/doom-emacs/archive/develop.tar.gz
	#	tar --gzip --extract --directory ${HOME}/.config/emacs --strip-components 1 --verbose --file=/tmp/doom.tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.config/emacs /tmp/doom.tar.gz
	rm /tmp/doom.tar.gz

update-asdf-vm:
	curl -s -L -o /tmp/asdf.tar.gz https://github.com/asdf-vm/asdf/archive/v0.8.0.tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.local/share/asdf /tmp/asdf.tar.gz
	rm /tmp/asdf.tar.gz

update-dein:
	curl -s -L -o /tmp/dein.tar.gz https://github.com/Shougo/dein.vim/archive/master.tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.cache/vimfiles/repos/github.com/Shougo/dein.vim /tmp/dein.tar.gz
	#	tar --gzip --extract --directory ${HOME}/.cache/vimfiles/repos/github.com/Shougo/dein.vim --strip-components 1 --verbose --file=/tmp/dein.tar.gz
	#	chezmoi add ${HOME}/.cache/vimfiles/repos/github.com/Shougo/dein.vim
	rm /tmp/dein.tar.gz

update-spacevim:
	curl -s -L -o /tmp/SpaceVim.tar.gz https://github.com/SpaceVim/SPaceVim/archive/v1.7.0.tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.local/share/SpaceVim /tmp/SpaceVim.tar.gz
	#	tar --gzip --extract --directory ${HOME}/.local/share/SpaceVim --verbose --strip-components=1 --file=/tmp/SpaceVim.tar.gz
	#	chezmoi add ${HOME}/.local/share/SpaceVim
	rm /tmp/SpaceVim.tar.gz

update-zimfw:
	curl -s -L https://github.com/zimfw/zimfw/releases/download/v1.4.3/zimfw.zsh.gz | gunzip -c > ${HOME}/.zim/zimfw.zsh
	chezmoi add ${HOME}/.zim/zimfw.zsh

update-tpm:
	# I have to use the HEAD revision since the last release was on 2015-08-03
	curl -s -L -o /tmp/tpm.tar.gz https://github.com/asdf-vm/asdf/archive/master.tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.tmux/plugins/tpm /tmp/tpm.tar.gz
	rm /tmp/tpm.tar.gz

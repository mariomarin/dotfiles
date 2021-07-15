all: install diff sync upgrade

# Versions
ASDF_VER ?= 0.8.1
DOOM_VER ?= develop
SPACEVIM_VER ?= 1.7.0
ZIM_VER ?= 1.4.3
DEIN_VER ?= 2.1
# use the HEAD revision since the last tag was on 2015-08-03
TPM_VER ?= master

all: init sync sync-tpm sync-doom sync-zimfw diff install \
	update update-doom update-asdf-vm update-dein update-zimfw update-tpm

init:
	chezmoi init "${CHEZMOI_REPO:-git@github.com:mariomarin/dotfiles.git}" --apply

sync: sync-tpm sync-doom sync-zimfw

sync-tpm:
	"${XDG_CONFIG_HOME}/tmux/plugins/tpm/bin/install_plugins"

sync-doom:
	"${DOOMDIR}/bin/doom" sync

sync-zimfw:
	source "${ZIM_HOME}/zimfw.zsh install"
	chezmoi add "${ZIM_HOME}/init.zsh"
	chezmoi add "${ZIM_HOME}/login_init.zsh"

diff:
	chezmoi source pull -- --rebase && chezmoi diff

install: update-all
	curl -sfL https://git.io/chezmoi | sh

update: update-asdf-vm update-zimfw update-spacevim update-tpm update-dein update-doom

update-doom:
	curl -s -L -o /tmp/doom.tar.gz https://github.com/hlissner/doom-emacs/archive/$(DOOM_VER).tar.gz
	#	tar --gzip --extract --directory ${HOME}/.config/emacs --strip-components 1 --verbose --file=/tmp/doom.tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.config/emacs /tmp/doom.tar.gz
	rm /tmp/doom.tar.gz

update-asdf-vm:
	curl -s -L -o /tmp/asdf.tar.gz https://github.com/asdf-vm/asdf/archive/v$(ASDF_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.local/share/asdf /tmp/asdf.tar.gz
	rm /tmp/asdf.tar.gz

update-dein:
	curl -s -L -o /tmp/dein.tar.gz https://github.com/Shougo/dein.vim/archive/refs/tags/$(DEIN_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.cache/vimfiles/repos/github.com/Shougo/dein.vim /tmp/dein.tar.gz
	rm /tmp/dein.tar.gz

update-spacevim:
	curl -s -L -o /tmp/SpaceVim.tar.gz https://github.com/SpaceVim/SPaceVim/archive/v$(SPACEVIM_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.local/share/SpaceVim /tmp/SpaceVim.tar.gz
	rm /tmp/SpaceVim.tar.gz

update-zimfw:
	curl -s -L https://github.com/zimfw/zimfw/releases/download/v$(ZIM_VER)/zimfw.zsh.gz | gunzip -c > ${HOME}/.zim/zimfw.zsh
	chezmoi add ${HOME}/.zim/zimfw.zsh

update-tpm:
	curl -s -L -o /tmp/tpm.tar.gz https://github.com/asdf-vm/asdf/archive/$(TPM_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.tmux/plugins/tpm /tmp/tpm.tar.gz
	rm /tmp/tpm.tar.gz

.PHONY: all $(MAKECMDGOALS)

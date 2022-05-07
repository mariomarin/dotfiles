all: install diff sync upgrade

# Versions
ASDF_VER ?= 0.8.1
DOOM_VER ?= develop
SPACEVIM_VER ?= 1.9.0
ZIM_VER ?= 1.4.3
# use the HEAD revision since the last tag was on 2015-08-03
TMUX_TPM_VER ?= master

all: init sync sync-tpm sync-doom sync-zimfw diff install \
	update update-doom update-asdf-vm update-zimfw update-tpm

init:
	chezmoi init "${CHEZMOI_REPO:-git@github.com:mariomarin/dotfiles.git}" --apply

sync: sync-tpm sync-doom sync-zimfw

sync-tpm:
	"${XDG_CONFIG_HOME}/tmux/plugins/tpm/bin/install_plugins"

sync-doom:
	"${DOOMDIR}/bin/doom" sync

sync-zimfw:
	zsh "${ZIM_HOME}/zimfw.zsh" install

diff:
	chezmoi source pull -- --rebase && chezmoi diff

install: update-all
	curl -sfL https://git.io/chezmoi | sh

update: update-asdf-vm update-zimfw update-spacevim update-tpm update-doom

update-doom:
	curl -s -L -o /tmp/doom.tar.gz https://github.com/hlissner/doom-emacs/archive/$(DOOM_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.config/emacs /tmp/doom.tar.gz
	rm /tmp/doom.tar.gz

update-asdf-vm:
	curl -s -L -o /tmp/asdf.tar.gz https://github.com/asdf-vm/asdf/archive/v$(ASDF_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.local/share/asdf /tmp/asdf.tar.gz
	rm /tmp/asdf.tar.gz

update-spacevim:
	curl -s -L -o /tmp/SpaceVim.tar.gz https://github.com/SpaceVim/SPaceVim/archive/v$(SPACEVIM_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.local/share/SpaceVim /tmp/SpaceVim.tar.gz
	rm /tmp/SpaceVim.tar.gz

update-zimfw:
	curl -s -L https://github.com/zimfw/zimfw/releases/download/v$(ZIM_VER)/zimfw.zsh.gz | gunzip -c > ${ZIM_HOME}/zimfw.zsh
	chezmoi add ${ZIM_HOME}/zimfw.zsh

update-tpm:
	curl -s -L -o /tmp/tpm.tar.gz https://github.com/tmux-plugins/tpm/archive/$(TMUX_TPM_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${HOME}/.tmux/plugins/tpm /tmp/tpm.tar.gz
	rm /tmp/tpm.tar.gz

.PHONY: all $(MAKECMDGOALS)

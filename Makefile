all: install diff sync upgrade

# Versions
AQUA_VER ?= v2.8.0
DEIN_VER ?= 115a782
DOOM_VER ?= develop
# SPACEVIM_VER ?= v2.1.0
SPACEVIM_VER ?= 3e96e13
ZIM_VER ?= 1.11.3
# use the HEAD revision since the last tag was on 2015-08-03
TMUX_TPM_VER ?= master
 
# Repositories
XMONAD_CFG_REPO := gitlab.com/dwt1/dotfiles
POLYBAR_PULSE_MOD_REPO := github.com/marioortizmanero/polybar-pulseaudio-control

all: init diff install sync sync-tpm sync-doom sync-zimfw \
	update update-doom update-asdf-vm update-zimfw update-tpm vendor-polybar-scripts

init:
	chezmoi init "${CHEZMOI_REPO:-git@github.com:mariomarin/dotfiles.git}" --apply

sync: sync-tpm sync-doom sync-zimfw sync-tpm

sync-tpm:
	${XDG_DATA_HOME}/tmux/plugins/tpm/bin/install_plugins
	${XDG_DATA_HOME}/tmux/plugins/tpm/bin/update_plugins all

sync-doom:
	"${DOOMDIR}/bin/doom" sync

sync-zimfw:
	zsh "${ZIM_HOME}/zimfw.zsh" install

apply:
	chezmoi apply -v

diff:
	chezmoi git pull -- --rebase && chezmoi diff

install: update-all
	curl -sfL https://git.io/chezmoi | sh
	curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/v2.1.1/aqua-installer | bash -s -- -v $(AQUA_VER)
	aqua i

update: update-zimfw update-dein update-spacevim update-tpm update-doom

update-dein:
	curl -s -L -o /tmp/dein.tar.gz https://github.com/Shougo/dein.vim/archive/$(DEIN_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${XDG_DATA_HOME}/SpaceVim/bundle/dein.vim /tmp/dein.tar.gz
	rm /tmp/dein.tar.gz

update-doom:
	curl -s -L -o /tmp/doom.tar.gz https://github.com/hlissner/doom-emacs/archive/$(DOOM_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${XDG_CONFIG_HOME}/emacs /tmp/doom.tar.gz
	rm /tmp/doom.tar.gz

update-spacevim:
	curl -s -L -o /tmp/SpaceVim.tar.gz https://github.com/SpaceVim/SPaceVim/archive/$(SPACEVIM_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${XDG_DATA_HOME}/SpaceVim /tmp/SpaceVim.tar.gz
	rm /tmp/SpaceVim.tar.gz

update-zimfw:
	curl -s -L https://github.com/zimfw/zimfw/releases/download/v$(ZIM_VER)/zimfw.zsh.gz | gunzip -c > ${ZIM_HOME}/zimfw.zsh
	chezmoi add ${ZIM_HOME}/zimfw.zsh

update-tpm:
	curl -s -L -o /tmp/tpm.tar.gz https://github.com/tmux-plugins/tpm/archive/$(TMUX_TPM_VER).tar.gz
	chezmoi import --strip-components 1 --destination ${XDG_DATA_HOME}/tmux/plugins/tpm /tmp/tpm.tar.gz
	rm /tmp/tpm.tar.gz

update-xmonad-config:
	go-getter -progress ${XMONAD_CFG_REPO}//.config/xmobar ${XDG_CONFIG_HOME}/xmobar
	chezmoi add ${XDG_CONFIG_HOME}/xmobar
	go-getter -progress ${XMONAD_CFG_REPO}//.config/xmonad ${XDG_CONFIG_HOME}/xmonad
	chezmoi add ${XDG_CONFIG_HOME}/xmonad
	go-getter -progress ${XMONAD_CFG_REPO}//.local/bin ${HOME}/.local/bin
	chezmoi add ${HOME}/.local/bin

vendor-polybar-scripts:
	rm -rf /tmp/pulseaudio-control
	go-getter ${POLYBAR_PULSE_MOD_REPO} /tmp/pulseaudio-control
	mv /tmp/pulseaudio-control/pulseaudio-control.bash ${HOME}/.local/bin/pulseaudio-control
	chezmoi add ${HOME}/.local/bin/pulseaudio-control

.PHONY: all $(MAKECMDGOALS)

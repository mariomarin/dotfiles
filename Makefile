all: install diff sync upgrade

TMUX_TPM_VER ?= master
 
# Repositories
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
	"${XDG_CONFIG_HOME}/emacs/bin/doom" sync

sync-zimfw:
	zsh "${ZIM_HOME}/zimfw.zsh" install

apply:
	chezmoi apply -v

diff:
	chezmoi git pull -- --rebase && chezmoi diff

install: update-all
	curl -sfL https://git.io/chezmoi | sh

vendor-polybar-scripts:
	rm -rf /tmp/pulseaudio-control
	go-getter ${POLYBAR_PULSE_MOD_REPO} /tmp/pulseaudio-control
	mv /tmp/pulseaudio-control/pulseaudio-control.bash ${HOME}/.local/bin/pulseaudio-control
	chezmoi add ${HOME}/.local/bin/pulseaudio-control

.PHONY: all $(MAKECMDGOALS)

all: install diff sync upgrade

TMUX_TPM_VER ?= master
 
# Repositories
POLYBAR_PULSE_MOD_REPO := github.com/marioortizmanero/polybar-pulseaudio-control

all: init diff install sync \
	update vendor-polybar-scripts

init:
	chezmoi init "${CHEZMOI_REPO:-git@github.com:mariomarin/dotfiles.git}" --apply

sync:

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

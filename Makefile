all: init diff install update

init:
	chezmoi init "${CHEZMOI_REPO:-git@github.com:mariomarin/dotfiles.git}" --apply

apply:
	chezmoi apply -v

diff:
	chezmoi git pull -- --rebase && chezmoi diff

install: update-all
	curl -sfL https://git.io/chezmoi | sh

.PHONY: all $(MAKECMDGOALS)

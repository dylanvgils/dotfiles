OS := $(shell uname -s)

# Stow packages for every platform
PACKAGES := tmux nvim zsh scripts

# macOS only
ifeq ($(OS),Darwin)
PACKAGES += ghostty
endif

# All recreates all dotfile symlinks to the home directory
all:
	stow --target=$$HOME --restow --no-folding ssh
	chmod 700 $$HOME/.ssh
	stow --target=$$HOME --restow $(PACKAGES)

# Init initializes the submodules and (re)creates the symlinks in the home directory
init: submodule.init all

# Update upates all submodules and recreates the symbolic liks in the home directory
update: pull submodule.update all

# Submodule.init initializes the submodules
submodule.init:
	git submodule update --init

# Submodule.update updates all the submodules
submodule.update:
	git submodule update --recursive --remote

# Delete removes all the symlinks from the home directory
delete:
	stow --target=$$HOME --delete */

# Pull pulls the latest refs from the remote repository
pull:
	git pull origin $$(git rev-parse --abbrev-ref HEAD)

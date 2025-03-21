# All recreates all dotfile symlinks to the home directory
all:
	stow --target=$$HOME --restow ssh
	stow --target=$$HOME --restow tmux
	stow --target=$$HOME --restow nvim
	stow --target=$$HOME --restow wezterm
	stow --target=$$HOME --restow zsh

# Init initializes the submodules and (re)creates the symlinks in th ehome directory
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

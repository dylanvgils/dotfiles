skip_global_compinit=1
source $HOME/.functions

# --- Exports ---

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# XDG - set defaults as they may not be set
# See https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
# and https://wiki.archlinux.org/title/XDG_Base_Directory#Support
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Global node_modules install path
export NPM_PACKAGES="$HOME/.local/share/npm"
export PATH=$PATH:$NPM_PACKAGES/share/man
export PATH=$PATH:$NPM_PACKAGES/bin

# Ssh agent variables
export SSH_ENV="$HOME/.ssh/environment"
export SSH_KEY_LIFETIME='4h'

# Include optional environment file
include ~/.zshenv.local

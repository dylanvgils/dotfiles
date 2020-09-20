skip_global_compinit=1
source $HOME/.functions

# --- Exports ---

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Global node_modules install path
export NPM_PACKAGES="$HOME/.npm-packages"
export PATH=$PATH:$NPM_PACKAGES/share/man
export PATH=$PATH:$NPM_PACKAGES/bin

# Ssh agent variables 
export SSH_ENV="$HOME/.ssh/environment"
export SSH_KEY_LIFETIME='4h'

# Include optional environment file
include ~/.zshenv.local

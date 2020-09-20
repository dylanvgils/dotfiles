skip_global_compinit=1

# Helper function for including optional files
include () {
    [[ -f "$1" ]] && source "$1"
}

# --- Exports ---

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Ssh agent variables 
export SSH_ENV="$HOME/.ssh/environment"
export SSH_KEY_LIFETIME='4h'

# Include optional environment file
include ~/.zshenv.local

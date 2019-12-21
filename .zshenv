skip_global_compinit=1

# --- Exports ---

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Go path
export GOPATH=$HOME/go

# Ssh agent variables 
export SSH_ENV="$HOME/.ssh/environment"
export SSH_KEY_LIFETIME='4h'

# Path
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

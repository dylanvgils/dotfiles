skip_global_compinit=1

# --- Exports ---

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Go path
export GOPATH=$HOME/go

# Node and npm path
export N_PREFIX="$HOME/.n"
export NPM_PACKAGES="$HOME/.npm-packages"

# Ssh agent variables 
export SSH_ENV="$HOME/.ssh/environment"
export SSH_KEY_LIFETIME='4h'

# Path
export PATH=$N_PREFIX/bin:$PATH
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export PATH=$PATH:$NPM_PACKAGES/share/man

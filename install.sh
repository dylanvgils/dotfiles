#!/bin/sh
#
# Variables
#
dotfiles_repo="https://github.com/dylanvgils/dotfiles.git"
dotfiles_dir="$HOME/dotfiles"

config_dir="$HOME/.config"

homebrew_install_script="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
omzsh_install_script="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
nvim_download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

#
# Functions
#
log_info() {
  echo "$1"
}

log_header() {
  log_info "\n========== $1 ==========\n"
}

create_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p $1
  fi
}

#
# Script
#
log_header "Start dotfiles installation"
log_info "Detecting platform..."
platform="unknown"

if [ "$(uname)" = "Linux" ]; then
  platform="linux"
elif [ "$(uname)" = "Darwin" ]; then
  platform="darwin"
else
  log_info "Platform '$OSTYPE' not supported"
  exit 1
fi

log_info "Platform '$platform' detected"

# Prepare system
if [ "$platform" = "darwin" ]; then
  log_header "Prepare system"

  # Ensure homebrew is installed
  if [ -z "$(which brew)" ]; then
    log_info "Install homebrew"
    /bin/bash -c "$(curl -fsSL $homebrew_install_script)"
    cp ./docs/examples/.zshrc.local ~/
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc.local
  else
    log_info "Update homebrew"
    brew update
  fi
fi

# Ensure config and local directories exist
create_dir "$HOME/.config"
create_dir "$HOME/.local/share"

# Update and install required packages
log_header "Install required packages"
if [ "$platform" = "linux" ]; then
  if [ -z "$(which apt)" ]; then
    log_info "Aptitute is not installed, exiting install script."
    exit 0
  fi

  log_header "Update package list"
  sudo apt update

  log_info "Install using aptitude (zsh, make, stow, curl, zip, xsel, fd, fzf, bat, build-essential)"
  sudo apt install -y git zsh make stow curl zip xsel fd-find fzf bat build-essential

  # Make sure ZSH is the default shell
  log_header "Change shell to ZSH"
  log_info "Current shell $SHELL"

  zsh_location="$(which zsh)"
  if [ "$SHELL" != "$zsh_location" ]; then
    log_info "Chaging default shell to zsh for $USER"
    chsh -s $(echo $zsh_location)
  fi
elif [ "$platform" = "darwin" ]; then
  log_info "Install using homebrew (git, stow, fd, fzf, bat, wezterm)"
  brew install git stow fd fzf bat
  brew install --cask wezterm
fi

# Install oh-my-zsh
log_header "Install oh-my-zsh"
if [ -z "${ZSH+x}" ]; then
  log_info "Install oh-my-zsh"

  export CHSH="no"
  export RUNZSH="no"

  sh -c "$(curl -fsSL $omzsh_install_script)"
else
  log_info ".oh-my-zsh directory exists, skipping install"
fi

# Make sure the latest version of the dotfiles are pulled
if [ -d "$dotfiles_dir" ]; then
  log_info "Make sure latest changes are pulled"
  git pull origin main
else
  log_info "Cloning dotfiles repository ($dotfiles_repo) in $dotfiles_dir"
  git clone $dotfiles_repo $dotfiles_dir
fi

# Remove existing configuration files so that they can be overriden later
log_header "Clean existing configuration"
log_info "Remove default config files"

config_files_to_remove=".aliases .completions .functions .zshenv .zshrc .zshrc.pre-oh-my-zsh .tmux.conf"
for item in $config_files_to_remove; do
  file="$HOME/$(echo "$item" | xargs)"
  if [ -f "$file" ]; then
    rm "$file"
    echo "Removed file: $file"
  fi
done

# Apply configuration
log_header "Apply dotfile configurations"

cd $dotfiles_dir
log_info "Soruce configuration files using included Makefile"
make init

# Install tmux
log_header "Install tmux"
if [ "$platform" = "linux" ]; then
  log_info "Install using aptitude"
  sudo apt install -y tmux
elif [ "$platform" = "darwin" ]; then
  log_info "Install using homebrew"
  brew install tmux
fi

log_info "Install tmux plugins"
export TMUX_PLUGIN_MANAGER_PATH="$config_dir/tmux/plugins"
$config_dir/tmux/plugins/tpm/bin/install_plugins

# Install lazygit
log_header "Install lazygit"
if [ "$platform" = "linux" ]; then
  log_info "Install from source"

  if [ -z "$(which lazygit)" ]; then
    lazygit_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_version}/lazygit_${lazygit_version}_Linux_x86_64.tar.gz"

    tar -xf /tmp/lazygit.tar.gz -C /tmp
    sudo install /tmp/lazygit -D -t /usr/local/bin/
    rm -r /tmp/lazygit.tar.gz /tmp/lazygit
  else
    log_info "Lazygit alread installed"
  fi
elif [ "$platform" = "darwin" ]; then
  log_info "Install using homebrew"
  brew install lazygit
fi

# Install Neovim (nvim)
log_header "Install neovim"
if [ "$platform" = "linux" ]; then
  log_info "Install from source"
  curl -Lo /tmp/nvim-linux64.tar.gz $nvim_download_url
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf /tmp/nvim-linux64.tar.gz
  rm /tmp/nvim-linux64.tar.gz

  log_info "Update alternatives, set nvim as default"
  sudo update-alternatives --install $(which vim) vim $(which nvim) 1
  sudo update-alternatives --set vim $(which nvim)
elif [ "$platform" = "darwin" ]; then
  log_info "Install using homebrew"
  brew install neovim
fi

# Run the new shell
log_header "Done! Start shell"
$SHELL

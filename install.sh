#!/bin/bash
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
  echo -e "$1"
}

log_header() {
  log_info "\n========== $1 ==========\n"
}

create_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

brew_has() {
  if brew list "$@" &>/dev/null; then
    log_info "$* already installed, skipping"
    return 0
  fi
  return 1
}

prepare_system_darwin() {
  if [ -z "$(which brew)" ]; then
    log_info "Install homebrew"
    /bin/bash -c "$(curl -fsSL $homebrew_install_script)"
    cp ./docs/examples/.zshrc.local ~/
    # shellcheck disable=SC2016 # written verbatim, expanded later when .zshrc.local is sourced
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zshrc.local
  else
    log_info "Update homebrew"
    brew update
  fi
}

install_packages_linux() {
  local apt_packages=(
    git
    zsh
    make
    stow
    curl
    zip
    xsel
    fd-find
    fzf
    bat
    ripgrep
    build-essential
  )

  log_header "Update package list"
  sudo apt update

  log_info "Install using aptitude (${apt_packages[*]})"
  sudo apt install -y "${apt_packages[@]}"
}

set_default_shell_linux() {
  local zsh_location

  log_header "Change shell to ZSH"
  log_info "Current shell $SHELL"

  zsh_location="$(which zsh)"
  if [ "$SHELL" != "$zsh_location" ]; then
    log_info "Chaging default shell to zsh for $USER"
    chsh -s "$zsh_location"
  fi
}

install_packages_darwin() {
  local brew_packages=(
    git
    stow
    ripgrep
    fd
    fzf
    bat
  )
  local pkg

  log_info "Install using homebrew (${brew_packages[*]} wezterm)"
  for pkg in "${brew_packages[@]}"; do
    brew_has "$pkg" || brew install "$pkg"
  done
  brew_has --cask wezterm || brew install --cask wezterm
}

install_tmux_linux() {
  log_info "Install using aptitude"
  sudo apt install -y tmux
}

install_tmux_darwin() {
  log_info "Install using homebrew"
  brew_has tmux || brew install tmux
}

install_lazygit_linux() {
  local lazygit_version

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
}

install_lazygit_darwin() {
  log_info "Install using homebrew"
  brew_has lazygit || brew install lazygit
}

install_neovim_linux() {
  local nvim_install_dir="/opt/nvim"
  local nvim_bin="$nvim_install_dir/bin/nvim"
  local nvim_tmp="/tmp/nvim-linux64.tar.gz"

  log_info "Install from source"
  curl -Lo "$nvim_tmp" "$nvim_download_url"
  sudo rm -rf "$nvim_install_dir"
  sudo mkdir -p "$nvim_install_dir"
  sudo tar -C "$nvim_install_dir" -xzf "$nvim_tmp" --strip-components=1
  rm "$nvim_tmp"
  sudo ln -sf "$nvim_bin" /usr/local/bin/nvim

  log_info "Update alternatives, set nvim as default"
  sudo update-alternatives --install /usr/bin/vim vim "$nvim_bin" 1
  sudo update-alternatives --set vim "$nvim_bin"
}

install_neovim_darwin() {
  log_info "Install using homebrew"
  brew_has neovim || brew install neovim
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
  prepare_system_darwin
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

  install_packages_linux
  set_default_shell_linux
elif [ "$platform" = "darwin" ]; then
  install_packages_darwin
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
  git clone "$dotfiles_repo" "$dotfiles_dir"
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

cd "$dotfiles_dir" || exit
log_info "Soruce configuration files using included Makefile"
make init

# Install tmux
log_header "Install tmux"
"install_tmux_${platform}"

log_info "Install tmux plugins"
export TMUX_PLUGIN_MANAGER_PATH="$config_dir/tmux/plugins"
"$config_dir"/tmux/plugins/tpm/bin/install_plugins

# Install lazygit
log_header "Install lazygit"
"install_lazygit_${platform}"

# Install Neovim (nvim)
log_header "Install neovim"
"install_neovim_${platform}"

# Run the new shell
log_header "Done! Start shell"
$SHELL

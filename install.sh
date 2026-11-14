#!/bin/bash
#
# Variables
#
dotfiles_repo="https://github.com/dylanvgils/dotfiles.git"
dotfiles_dir="$HOME/dotfiles"
dotfiles_examples_dir="$dotfiles_dir/docs/examples"

config_dir="$HOME/.config"

homebrew_install_script="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
omzsh_install_script="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
sdkman_install_script="https://get.sdkman.io?rcupdate=false"
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

# Puts brew on PATH for this script (Apple Silicon or Intel location)
load_brew_env() {
  local brew_bin
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew_bin" ]; then
      eval "$("$brew_bin" shellenv)"
      return 0
    fi
  done
  return 1
}

prepare_system_darwin() {
  if [ -z "$(command -v brew)" ]; then
    load_brew_env
  fi

  if [ -z "$(command -v brew)" ]; then
    log_info "Install homebrew"
    /bin/bash -c "$(curl -fsSL $homebrew_install_script)"
    load_brew_env || {
      log_info "Homebrew not found after install, exiting install script."
      exit 1
    }
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
    unzip
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

  # fd-find installs its binary as `fdfind` on Debian/Ubuntu since `fd` was already taken
  if [ -z "$(which fd)" ] && [ -n "$(which fdfind)" ]; then
    log_info "Symlinking fdfind to fd"
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
  fi
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

setup_packages_linux() {
  if [ -z "$(which apt)" ]; then
    log_info "Aptitute is not installed, exiting install script."
    exit 0
  fi

  install_packages_linux
  set_default_shell_linux
}

# Puts brew on PATH in new shells via ~/.zshrc.local, created from the example if missing
setup_brew_shellenv_darwin() {
  local zshrc_local="$HOME/.zshrc.local"

  if [ ! -f "$zshrc_local" ]; then
    cp "$dotfiles_examples_dir/.zshrc.local" "$zshrc_local"
  fi

  if ! grep -q "brew shellenv" "$zshrc_local"; then
    log_info "Add brew shellenv to $zshrc_local"
    echo "eval \"\$($(command -v brew) shellenv)\"" >>"$zshrc_local"
  fi
}

setup_packages_darwin() {
  log_info "Install using homebrew bundle"
  brew bundle --file="$dotfiles_dir/Brewfile"
}

# Installs SDKMAN without touching the (stowed) shell rc files
install_sdkman() {
  export SDKMAN_DIR="$HOME/.local/share/sdkman"

  if [ -d "$SDKMAN_DIR" ]; then
    log_info "SDKMAN already installed"
    return
  fi

  log_info "Install using the official installer"
  curl -fsSL "$sdkman_install_script" | bash
}

install_tmux_linux() {
  log_info "Install using aptitude"
  sudo apt install -y tmux
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

# Update and install required packages (darwin installs from the Brewfile after cloning)
if [ "$platform" = "linux" ]; then
  log_header "Install required packages"
  setup_packages_linux
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
  git -C "$dotfiles_dir" pull origin main
else
  log_info "Cloning dotfiles repository ($dotfiles_repo) in $dotfiles_dir"
  git clone "$dotfiles_repo" "$dotfiles_dir"
fi

if [ "$platform" = "darwin" ]; then
  setup_brew_shellenv_darwin

  log_header "Install required packages"
  setup_packages_darwin
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

# Install tmux, lazygit and neovim (darwin has them in the Brewfile)
if [ "$platform" = "linux" ]; then
  log_header "Install tmux"
  install_tmux_linux

  log_header "Install lazygit"
  install_lazygit_linux

  log_header "Install neovim"
  install_neovim_linux
fi

log_header "Install SDKMAN"
install_sdkman

log_header "Install tmux plugins"
export TMUX_PLUGIN_MANAGER_PATH="$config_dir/tmux/plugins"
"$config_dir"/tmux/plugins/tpm/bin/install_plugins

# Run the new shell
log_header "Done! Start shell"
$SHELL

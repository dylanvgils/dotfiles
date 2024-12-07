#! /bin/sh
#
# Variables
#
dotfiles_repo="git@github.com:dylanvgils/dotfiles.git"
dotfiles_dir="$HOME/dotfiles"

config_dir="$HOME/.config"

omzsh_install_script="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

#
# Functions
#
log_info() {
  echo "$1"
}

log_header() {
  log_info "\n========== $1 ==========\n"
}

#
# Script
#
log_header "Start dotfiles installation"

# Make sure the package list is up-to-date
log_header "Update package list"
sudo apt update

# Install required packages
log_header "Install required packages (zsh, make, stow, curl)"
sudo apt install -y git zsh make stow curl

# Make sure ZSH is the default shell
log_header "Change shell to ZSH"
log_info "Current shell $SHELL"

zsh_location="$(which zsh)"
if [ "$SHELL" != "$zsh_location" ]; then
  log_info "Chaging default shell to zsh for $USER"
  chsh -s $(echo $zsh_location)
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
sudo apt install -y tmux

log_info "Install tmux plugins"
$config_dir/tmux/plugins/tpm/bin/install_plugins

# Install lazygit
log_header "Install lazygit"
if [ -z "$(which lazygit)" ]; then
  lazygit_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_version}/lazygit_${lazygit_version}_Linux_x86_64.tar.gz"

  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
  rm -r lazygit.tar.gz lazygit
else
  log_info "Lazygit alread installed"
fi

# Run the new shell
log_header "Done! Start shell"
$SHELL


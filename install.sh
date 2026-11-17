#!/bin/bash
#
# Variables
#
dotfiles_repo="https://github.com/dylanvgils/dotfiles.git"
dotfiles_dir="$HOME/dotfiles"
dotfiles_examples_dir="$dotfiles_dir/docs/examples"
dotfiles_brew_dir="$dotfiles_dir/brew"

config_dir="$HOME/.config"

homebrew_install_script="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
omzsh_install_script="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
sdkman_install_script="https://get.sdkman.io?rcupdate=false"

# Linux release binaries, GitHub repo and asset name (%s is the version)
bin_dir="/usr/local/bin"
lazygit_repo="jesseduffield/lazygit"
lazygit_asset="lazygit_%s_linux_x86_64.tar.gz"
nvim_repo="neovim/neovim"
nvim_asset="nvim-linux-x86_64.tar.gz"
nvim_install_dir="/opt/nvim"
cosign_repo="sigstore/cosign"
cosign_asset="cosign-linux-amd64"

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

# Prints the latest release JSON of a GitHub repo (owner/name)
github_latest_release() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest"
}

# Prints the version of a release JSON, without the "v" prefix
release_version() {
  jq -r '.tag_name // empty | ltrimstr("v")' <<<"$1"
}

# Downloads a release asset and checks it against GitHub's sha256 digest
# Usage: download_release_asset <release json> <asset name> <output file>
download_release_asset() {
  local release="$1" asset="$2" output="$3"
  local url digest

  url=$(jq -r --arg name "$asset" '.assets[] | select(.name == $name) | .browser_download_url // empty' <<<"$release")
  digest=$(jq -r --arg name "$asset" '.assets[] | select(.name == $name) | .digest // empty' <<<"$release")

  if [ -z "$url" ] || [[ "$digest" != sha256:* ]]; then
    log_info "No download or checksum found for $asset, skipping"
    return 1
  fi

  curl -fL --progress-bar -o "$output" "$url" || return 1

  if ! echo "${digest#sha256:}  $output" | sha256sum --check --quiet; then
    log_info "Checksum mismatch for $asset, skipping"
    rm -f "$output"
    return 1
  fi

  log_info "Checksum OK for $asset"
}

# Prints the version of an installed command, empty when missing
# Usage: installed_version <grep -P pattern> <command> [args...]
installed_version() {
  local pattern="$1"
  shift

  if [ -n "$(command -v "$1")" ]; then
    "$@" 2>&1 | grep -m1 -Po "$pattern"
  fi
}

# Succeeds when the latest version is known and differs from the installed one
needs_install() {
  local name="$1" installed="$2" latest="$3"

  if [ -z "$latest" ]; then
    log_info "Could not get the latest $name version, skipping"
    return 1
  fi

  if [ "$installed" = "$latest" ]; then
    log_info "$name $installed is up to date"
    return 1
  fi

  log_info "Install $name $latest (installed: ${installed:-none})"
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
    tmux
    fd-find
    fzf
    bat
    ripgrep
    jq
    shellcheck
    build-essential
  )

  log_header "Update package list"
  sudo apt update

  log_info "Install using aptitude (${apt_packages[*]})"
  sudo apt install -y "${apt_packages[@]}"

  # fd-find installs its binary as `fdfind` on Debian/Ubuntu since `fd` was already taken
  if [ -z "$(which fd)" ] && [ -n "$(which fdfind)" ]; then
    log_info "Symlinking fdfind to fd"
    sudo ln -sf "$(which fdfind)" "$bin_dir/fd"
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
  brew bundle --file="$dotfiles_brew_dir/Brewfile"

  # Opt-in App Store apps, brew only passes HOMEBREW_* variables to the Brewfile
  if [ -n "$DOTFILES_MAS_APPS" ]; then
    log_info "\nInstall Mac App Store apps from DOTFILES_MAS_APPS"
    HOMEBREW_DOTFILES_MAS_APPS="$DOTFILES_MAS_APPS" brew bundle --file="$dotfiles_brew_dir/Brewfile.mas"
  fi
}

# Installs SDKMAN without touching the (stowed) shell rc files
install_sdkman() {
  export SDKMAN_DIR="$HOME/.local/share/sdkman"

  if [ -d "$SDKMAN_DIR" ]; then
    log_info "SDKMAN already installed, updating"
    # shellcheck source=/dev/null
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk selfupdate
    return
  fi

  log_info "Install using the official installer"
  curl -fsSL "$sdkman_install_script" | bash
}

install_lazygit_linux() {
  local release latest installed

  release=$(github_latest_release "$lazygit_repo")
  latest=$(release_version "$release")
  installed=$(installed_version 'version=\K[0-9.]+' lazygit --version)

  needs_install lazygit "$installed" "$latest" || return 0

  # shellcheck disable=SC2059 # the asset name is the format string
  download_release_asset "$release" "$(printf "$lazygit_asset" "$latest")" /tmp/lazygit.tar.gz || return 1
  tar -xf /tmp/lazygit.tar.gz -C /tmp
  sudo install /tmp/lazygit -D -t "$bin_dir/"
  rm -r /tmp/lazygit.tar.gz /tmp/lazygit
}

install_neovim_linux() {
  local nvim_bin="$nvim_install_dir/bin/nvim"
  local nvim_tmp="/tmp/nvim-linux64.tar.gz"
  local release latest installed

  release=$(github_latest_release "$nvim_repo")
  latest=$(release_version "$release")
  installed=$(installed_version 'NVIM v\K[0-9.]+' "$nvim_bin" --version)

  needs_install neovim "$installed" "$latest" || return 0

  download_release_asset "$release" "$nvim_asset" "$nvim_tmp" || return 1
  sudo rm -rf "$nvim_install_dir"
  sudo mkdir -p "$nvim_install_dir"
  sudo tar -C "$nvim_install_dir" -xzf "$nvim_tmp" --strip-components=1
  rm "$nvim_tmp"
  sudo ln -sf "$nvim_bin" "$bin_dir/nvim"

  log_info "Update alternatives, set nvim as default"
  sudo update-alternatives --install /usr/bin/vim vim "$nvim_bin" 1
  sudo update-alternatives --set vim "$nvim_bin"
}

install_cosign_linux() {
  local cosign_tmp="/tmp/cosign-linux-amd64"
  local release latest installed

  release=$(github_latest_release "$cosign_repo")
  latest=$(release_version "$release")
  installed=$(installed_version 'GitVersion:\s+v\K[0-9.]+' cosign version)

  needs_install cosign "$installed" "$latest" || return 0

  download_release_asset "$release" "$cosign_asset" "$cosign_tmp" || return 1
  sudo install "$cosign_tmp" "$bin_dir/cosign"
  rm "$cosign_tmp"
}

# Updates all tmux plugins except tpm, a submodule (detached HEAD) updated by git
update_tmux_plugins() {
  local plugin_dir plugin
  local plugins=()

  for plugin_dir in "$TMUX_PLUGIN_MANAGER_PATH"/*/; do
    plugin=$(basename "$plugin_dir")
    if [ "$plugin" != "tpm" ]; then
      plugins+=("$plugin")
    fi
  done

  if [ ${#plugins[@]} -gt 0 ]; then
    "$TMUX_PLUGIN_MANAGER_PATH"/tpm/bin/update_plugins "${plugins[@]}"
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
  log_info "oh-my-zsh already installed, updating"
  ZSH="$ZSH" zsh -f "$ZSH/tools/upgrade.sh"
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

# Install lazygit, neovim and cosign (darwin has them in the Brewfile)
if [ "$platform" = "linux" ]; then
  log_header "Install lazygit"
  install_lazygit_linux

  log_header "Install neovim"
  install_neovim_linux

  log_header "Install cosign"
  install_cosign_linux
fi

log_header "Install SDKMAN"
install_sdkman

log_header "Install tmux plugins"
export TMUX_PLUGIN_MANAGER_PATH="$config_dir/tmux/plugins"
"$config_dir"/tmux/plugins/tpm/bin/install_plugins
update_tmux_plugins

# Run the new shell, `dotfiles update` reloads the current shell instead
if [ -n "$DOTFILES_UPDATE" ]; then
  log_header "Done!"
else
  # Start zsh directly, $SHELL may still be the old login shell until the next login
  log_header "Done! Start zsh"
  SHELL="$(command -v zsh)" exec zsh
fi

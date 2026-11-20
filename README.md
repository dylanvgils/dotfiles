# Dotfiles

> Dotfiles allow sharing of configuration files across multiple computers, with the convenience of using git.

This repository contains my shell configuration files (a.k.a dotfiles). It can be cloned to the home directory and installed (or removed) with the included `Makefile`. The sections below describe how this repositry can be used.

The easiest way to install the dotfiles is to use the install script, which can be executed with the following command:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dylanvgils/dotfiles/main/install.sh)"
```

On macOS, Mac App Store apps are opt-in by App Store ID, space-separated (find an ID with `mas search <app>` or in the app's App Store URL). To install them on the first run:

```sh
DOTFILES_MAS_APPS="<app-store-id>" bash -c "$(curl -fsSL https://raw.githubusercontent.com/dylanvgils/dotfiles/main/install.sh)"
```

To keep them on later `dotfiles update` runs, add the export to `~/.zshenv.local`:

```sh
export DOTFILES_MAS_APPS="<app-store-id>"
```

## 1. Prerequisites

Make sure the following packages are installed on the system:

- [git](https://git-scm.com/)
- [zsh](https://www.zsh.org/)
- [make](https://www.gnu.org/software/make/)
- [stow](https://www.gnu.org/software/stow/)
- [oh-my-zsh](https://ohmyz.sh/)

For example, run the following commands to install the packages:

```sh
# Ubuntu (or other distros using Aptitude)
sudo apt-get update && sudo apt-get install git zsh make stow

# Fedora (or other distros using dnf)
sudo dnf install git zsh make stow

# macOS (installs everything in the Brewfile, run from the repository root)
brew bundle --file=brew/Brewfile
```

For installing `oh-my-zsh`, use the script listed on their [website](https://ohmyz.sh/#install).

## 2. Installing

This section describes how the dotfiles can be installed in your home directory, `stow` and `make` are the tools to make this as easy as possible.

## 2.1 Clone the repository

This first step is cloning this repostory to your system, use the following commands:

```sh
# Change the directory to the home directory
cd ~

# Clone the repository
# For http(s):
git clone https://github.com/dylanvgils/dotfiles.git
# OR, for ssh:
git clone git@github.com:dylanvgils/dotfiles.git
```

## 2.2 Symlink the configuration files

Once the repository is cloned to the system, `make` can be used to symlink the configuration in the repository to the home directory.

> **NOTE:** existing files are not overridden, which should be solved first. Either delete or move the file out of the home directory.

To make the configuration active on your system, you can execute the following commands:

```sh
# Change directory to the dotfiles repository root
cd ~/dotfiles

# Run the initialize command
make init

# Source the newly added configuration
source ~/.zshenv && source ~/.zshrc
```

## 2.3 Update the configuration to the latest version

The install script is idempotent, re-running it updates everything: the dotfiles, packages (brew/apt), the Linux release binaries (lazygit, neovim, cosign), oh-my-zsh, SDKMAN and the tmux plugins. The `dotfiles` command re-runs it:

```sh
dotfiles update
```

After adding a new file to a package (e.g. a script in `scripts/.local/scripts/`), re-create the symlinks and reload the shell:

```sh
dotfiles stow
```

## 2.4 Uninstall the dotfiles from the system

The `Makefile` also contains a target to remove all the symlinks fro the home directory. To Uninstall the shell configuration execute the following commands:

> **NOTE:** The easiest way to make the changes affective is to logout an back in again. This will reload the entire shell configuration.

```sh
# Change directory to the dotfiles repository root
cd ~/dotfiles

# Run the stow command using make
make delete
```

## 3. Managing submodules

Git submodules are used to manage shell dependencies. This section describes how submodules can be added, updated or removed from the repository.

### 3.1 Add submodule

Let say that we want to install the `bar` plugin in the `.vim` directory, using Vim 8's package feature:

```bash
# Change directory into the module directory
cd ~/dotfiles/vim

# Add the submodule in the desired location
git submodule add git@github.com/username/foo.git pack/plugins/start/foo

# Commit the changes to the repository
git commit -m "Add bar submodule to vim"

# Reload the shell configuration
dotfiles reload
```

### 3.2 Removing submodule

Once a module is obsolete or is not used anymore, use the following commands to remove submodule `bar`:

```bash
# Change directory into the module directory
cd ~/dotfiles/vim

# De-init the submodule
git submodule deinit .vim/pack/plugins/start/bar

# Remove the directory from the sources
git rm -r .vim/pack/plugins/start/bar

# Remove the submodule from the .dit directory
rm -r .git/modules/vim/.vim/pack/plugins/start/bar
```

### 3.3 Update submodule

Once in a while submodules have to be updated, the following commands can be used to update the module `bar`:

> **NOTE:** git submodule update will not commit the changes to the repository. Make sure that the changes are committed to the repository when you are done updating.

```bash
# Change directory into the module directory
cd ~/vim/.vim/pack/plugins/start/bar

# Pull changes from the desired branch (e.g. main)
git pull origin main
```

It is also possible to update all the submodules at once, to update all the modules execute the following command:

```bash
# Change directory into the dotfiles directory
cd ~/dotfiles

# Update the submodules
make update
# OR, use the git command
git submodule update --recursive --remote

# Reload the shell configuration
dotfiles reload
```

## 4. System specific configuration

For the `.aliases`, `.completion`, `.zshrc` and `.zshenv` files a local version can also be created by creating a file with the `.local`-suffix (e.g. .aliases.local). An example of these files is included in the repository. The .local files can be used to configure system specific aliases, completions and environment variables. The changes made to the .local files will not be committed and thus will not affect other systems. For some examples see the files below:

- [.aliases.local](docs/examples/.aliases.local)
- [.completion.local](docs/examples/.completion.local)
- [.zshrc.local](docs/examples/.zshrc.local)
- [.zshenv.local](docs/examples/.zshenv.local)

## 5. Testing the install script

The install script can be tested on Linux in a fresh Ubuntu container, this requires Docker. The container uses the local repository, including uncommitted changes, and is removed on exit.

1. Run the install script in the container:

   ```sh
   cd ~/dotfiles
   make test.linux
   ```

2. Check that the script ends in a zsh shell, without "Checksum mismatch" or tmux plugin errors.

3. Check the `dotfiles` command and its completion:

   ```sh
   dotfiles <tab>    # lists stow, update and reload
   dotfiles update   # all release binaries are "up to date", the shell reloads
   ```

4. Exit the shell to remove the container.

> **NOTE:** The script pulls `main` from GitHub, which fails when an uncommitted change conflicts with it. The script continues with the local files in that case.

## Known issues

The `docs` folder contains a [issues.md](docs/issues.md) file, this file describes the known issues in the repository.

---

## References

- [Manage Dotfiles With a Bare Git Repository](https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html)
- [Using git-submodules to version-control Vim plugins](https://gist.github.com/manasthakur/d4dc9a610884c60d944a4dd97f0b3560)
- [Using ssh-agent with ssh](http://mah.everybody.org/docs/ssh)
- [Managing dotfiles with GNU stow](https://venthur.de/2021-12-19-managing-dotfiles-with-stow.html)

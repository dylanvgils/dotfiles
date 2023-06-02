# Dotfiles

> Dotfiles allow sharing of configuration files across multiple computers, with the convenience of using git.

This repository contains my shell configuration files (a.k.a dotfiles). It can be cloned to the home directory and installed (or removed) with the included `Makefile`. The sections below describe how this repositry can be used.

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
To update the dotfiles to the latest version execute the following commands:

```sh
# Change directory to the dotfiles repository root
cd ~/dotfiles

# Pull the latest changes from the remote
git pull origin main

# Run the stow command using make (implicit call to 'all' target)
make

# Reload the shell configuration
reload.env && reload.zsh
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
reload.env && reload.zsh
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
reload.env && reload.zsh
```

## 4. System specific configuration

For the `.aliases`, `.completion`, `.zshrc` and `.zshenv` files a local version can also be created by creating a file with the `.local`-suffix (e.g. .aliases.local). An example of these files is included in the repository. The .local files can be used to configure system specific aliases, completions and environment variables. The changes made to the .local files will not be committed and thus will not affect other systems. For some examples see the files below:

- [.aliases.local](docs/examples/.aliases.local)
- [.completion.local](docs/examples/.completion.local)
- [.zshrc.local](docs/examples/.zshrc.local)
- [.zshenv.local](docs/examples/.zshenv.local)

## Known issues
The `docs` folder contains a [issues.md](docs/issues.md) file, this file describes the known issues in the repository.

---

## References

- [Manage Dotfiles With a Bare Git Repository](https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html)
- [Using git-submodules to version-control Vim plugins](https://gist.github.com/manasthakur/d4dc9a610884c60d944a4dd97f0b3560)
- [Using ssh-agent with ssh](http://mah.everybody.org/docs/ssh)
- [Managing dotfiles with GNU stow](https://venthur.de/2021-12-19-managing-dotfiles-with-stow.html)

# Using git-submodules (dotfiles) to manage shell configuration

This readme is intended to describe the process of setting up and using git-submodules (dotfiles)
to manage the configuration (dotfiles) on your system. Using git-submodules allows to distribute
those configurations across multiple computers, with the convenience of using git.

## 1. Installing

### 1.1 Creating the repository

The **first step** of managing the configuration in your home directory is creating new bare git repository.
Creating the bare git repository can be done with the following command:

```bash
git init --bare $HOME/.dotfiles.git
```

The **second step** is creating an alias in the `.zshrc` or `.bashrc` file, e.g.:

```bash
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
```

or use one of the commands below:

```bash
# For zsh use:
echo 'alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"' >> $HOME/.zshrc

# For bash use:
echo 'alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"' >> $HOME/.bashrc
```

The **third step** is reloading the sell setting, use one of the following commands:

```bash
# For zsh use:
source ~/.zshrc

# For bash use
source ~/.bashrc
```

The **fourth step** is setting the remote of the git repository:

```bash
dotfiles remote add origin git@github.com/dylanvgils/dotfiles.git
```

**Optionally** you can set the `showUntrackedFiles` to `no` to hide the untracked files when calling `git status`.
This can be done with the following command:

```bash
dotfiles config --local status.showUntrackedFiles no
```

### 1.2 Installing dotfiles on another system

This first chapter of this readme described how the dotfiles can be setup on a system. Copying the dotfiles to another system can be done with the following steps:

```bash
echo 'alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"' >> $HOME/.zshrc
source ~/.zshrc
git clone --bare git@github.com:dylanvgils/dotfiles.git $HOME/.dotfiles.git
dotfiles checkout
dotfiles submodule update --init
```

1) Add the `dotfiles` alias to your shell configuration.
2) Reload the shell settings to use the alias.
3) Clone the repository.
4) If you already have configuration files with identical names, checkout will fail.

## 2. Managing submodules

### 2.1 Add submodule

Let say that we want to install the `bar` plugin in the `.vim` directory, using Vim 8's package feature:

```bash
cd ~/.vim
dotfiles submodule add git@github.com/username/foo.git pack/plugins/start/foo
dotfiles commit -m "Added submodules."
```

### 2.2 Removing submodule

To remove submodule `foo`:

```bash
cd ~/.vim
git submodule deinit pack/plugins/start/foo
git rm -r pack/plugins/start/foo
rm -r ~/dotfiles.git/modules/pack/plugins/start/foo
```

### 2.3 Update submodule

To update `foo`:

```bash
cd ~/.vim/pack/plugins/start/foo
dotfiles pull origin master
```

To update all submodules:

```bash
cd ~/
dotfiles submodule update --recursive --remote
```

Updating submodules will create uncommitted changes in the dotfiles repository. So when submodules are updated, you need to commit the dotfiles repository as well:

```bash
cd ~/
dotfiles commit -am "Updated plugins."
```

## 3. References

- [Manage Dotfiles With a Bare Git Repository](https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html)
- [Using git-submodules to version-control Vim plugins](https://gist.github.com/manasthakur/d4dc9a610884c60d944a4dd97f0b3560)
- [Using ssh-agent with ssh](http://mah.everybody.org/docs/ssh)

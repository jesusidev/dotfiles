# Dotfiles

Dotfiles for macos & New Mac Setup

## Usage for syncing .config

Moving from Lunar VIM to Lazy VIM

```shell
rm -rf ~/.config/lvim
rm -rf ~/.local/share/lvim
rm -rf ~/.cache/lvim
rm -rf ~/.local/state/lvim
```

```shell
$ git clone git@github.com:gdevtech/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles
$ ./setupConfig.sh
$ update
$ tmux
$ update-tmux
```

### Installing TMUX plugins

1. Press <kbd>ctrl a</kbd> + <kbd>I</kbd> (capital i, as in **I**nstall) to fetch the plugin.

### New Mac Setup

```shell
$ cd ~/.dotfiles
$ cd scripts
$ ./appsInstallation.sh
$ cd ~/.dotfiles
$ ./setupConfig.sh
```

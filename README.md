# Dotfiles

Provisions a new Mac: zsh (with Zap plugins and Starship), Neovim (LazyVim), Ghostty, Git and macOS system settings.

## New Mac

```shell
git clone https://github.com/jesusidev/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles
./install.sh --dry-run   # preview
./install.sh
```

`install.sh` is safe to re-run. In order, it:

1. Installs the Xcode command line tools and waits for them to finish.
2. Installs Homebrew and the packages in `Brewfile`.
3. Installs Zap (zsh plugin manager).
4. Writes your Git name, email and signing key to `~/.gitconfig.local` (not committed), taking them from an existing `~/.gitconfig` or asking. Creates `~/.ssh/id_ed25519` only if it is missing.
5. Links the configs into `$HOME` with stow. Any real file it would replace is moved to `~/.dotfiles-backup/<time>/` first.
6. Applies macOS settings (`macos.sh`; skip with `--no-macos`).

After it finishes, open Ghostty, start a new shell (Zap installs plugins on first launch), then run `nvim` once so LazyVim installs its plugins.

## What is linked

| Folder     | Ends up at                   |
|------------|------------------------------|
| `zshrc`    | `~/.zshrc`                   |
| `git`      | `~/.gitconfig`               |
| `nvim`     | `~/.config/nvim`             |
| `ghostty`  | `~/.config/ghostty`          |
| `starship` | `~/.config/starship.toml`    |
| `tmux`     | `~/.config/tmux`             |

tmux plugins (TPM) are installed into `~/.config/tmux/plugins` by `install.sh` and are gitignored. Prefix is `Ctrl-a`; `Ctrl-a` then `Shift-i` installs any newly added plugin.

Machine-specific shell settings or secrets go in `~/.zshrc.local` (sourced at the end of `.zshrc`, never committed).

## Extras

`extras/` holds configs that are no longer installed by default (yabai, skhd, iTerm, OpenCode, Claude). To link one by hand:

```shell
stow --dir ~/repos/dotfiles/extras --target ~ yabai
```

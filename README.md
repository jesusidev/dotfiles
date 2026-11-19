# Dotfiles

Provisions a new Mac: zsh (Zap plugins and Starship prompt), Neovim (LazyVim), Ghostty, tmux, Git, everyday apps and macOS system settings. Everything is installed with Homebrew and linked into place with stow.

## New Mac

```shell
git clone https://github.com/jesusidev/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles
./install.sh --dry-run   # preview, changes nothing
./install.sh
```

Options: `--dry-run` prints what would happen; `--no-macos` skips the macOS settings.

`install.sh` is safe to re-run: each step checks first and skips what is already done, so a second run only adds what is new. In order, it:

1. Installs the Xcode command line tools and waits for them to finish.
2. Installs Homebrew and everything in `Brewfile`. Apps you installed by hand are adopted by Homebrew, not reinstalled.
3. Installs Zap (zsh plugin manager). It is cloned directly because Zap's own installer overwrites `~/.zshrc`.
4. Writes your Git name, email and signing key to `~/.gitconfig.local` (never committed), taken from an existing `~/.gitconfig` or asked for. Creates `~/.ssh/id_ed25519` only if it is missing.
5. Uploads that SSH key to GitHub as an authentication and a signing key, only if it is not already there. Checking signing keys needs one extra `gh` permission: `gh auth refresh -h github.com -s admin:ssh_signing_key`.
6. Links the configs into `$HOME` with stow. A real file that would be replaced is moved to `~/.dotfiles-backup/<time>/` first (use `ls -A` to see it). Existing links are left alone.
7. Installs TPM and the tmux plugins.
8. Applies macOS settings from `macos.sh`.

### After the first run

1. Open Ghostty and start a new shell. Zap downloads the zsh plugins on first launch.
2. Run `nvim` once. LazyVim installs its plugins and Mason installs the language tools.
3. Open Rancher Desktop and choose **Configure PATH: Manual**. `.zshrc` already adds `~/.rd/bin`; Automatic would write into `.zshrc`, which is this repo's file.
4. Sign in to the paid apps (CleanShot, Presentify, Sublime Text, Raycast).

## What is linked

The files live in this repo; the paths below are symlinks to them, so editing either place edits the repo. Don't move the repo after installing; if you do, run `./install.sh` again from the new location.

| Folder     | Linked at                  |
|------------|----------------------------|
| `zshrc`    | `~/.zshrc`, `~/.zshenv` (Volta PATH) and `~/.config/zsh` (extra function files) |
| `git`      | `~/.gitconfig`             |
| `nvim`     | `~/.config/nvim`           |
| `ghostty`  | `~/.config/ghostty`        |
| `starship` | `~/.config/starship.toml`  |
| `tmux`     | `~/.config/tmux`           |

Not in git, per machine:

- `~/.zshrc.local`: machine-specific shell settings or secrets, sourced at the end of `.zshrc`. Keep it private with `chmod 600 ~/.zshrc.local`. This repo is public, so account IDs, usernames and tokens belong here, not in the repo.
- `~/.gitconfig.local`: Git name, email and signing key, included by `.gitconfig`.

## Apps and tools (Brewfile)

Homebrew is the one way apps are managed here. To add one, add a line to `Brewfile` and run `brew bundle --file ~/repos/dotfiles/Brewfile`; `brew upgrade` updates everything. Find an app's name with `brew search <name>`.

- **Shell:** stow, git, gh, starship, eza, fzf
- **Node:** volta (see below)
- **AWS:** awscli
- **tmux:** tmux, zoxide, dark-notify
- **Neovim:** neovim, tree-sitter, ripgrep, fd, lazygit, go, python, Temurin (JDK). Mason uses Node (from Volta), go, python and Java to build the language servers.
- **Terminal and fonts:** Ghostty, JetBrains Mono, Symbols Nerd Font
- **Apps:** Raycast, Presentify, CleanShot, JetBrains Toolbox, OBS, Paper, Postman, Rancher Desktop, Routine, Sublime Text

`dark-notify` comes from a third-party tap, which Homebrew only installs once trusted; the Brewfile marks just that one formula `trusted: true`.

### Node with Volta

Node comes only from Volta, not Homebrew. In a repo whose `package.json` has a `"volta"` pin, `node` and `npm` are that version automatically; everywhere else they are Volta's default, which `install.sh` sets to Node 26 (`VOLTA_DEFAULT_NODE`). Volta's `~/.volta/bin` is put ahead of Homebrew in both `.zshenv` (every zsh, including scripts) and `.zshrc` (after `brew shellenv`, which would otherwise put Homebrew first).

```shell
volta install node@26   # change the default
volta pin node@24       # pin the current repo (writes package.json)
volta list              # what is installed
```

## zsh

Aliases live in `zshrc/.zshrc`. A few common ones:

| Alias | Runs |
|---|---|
| `l` / `ll` / `la` | `eza` listings with icons |
| `gs`, `gp`, `gd`, `gc "msg"` | git status / pull / diff / commit |
| `gpush "msg"` | add, commit and push |
| `lg` | lazygit |
| `update` | reload `.zshrc` |
| `update-tmux` | reload the tmux config |

## AWS

Functions in `zshrc/.config/zsh/aws.zsh`, loaded by `.zshrc`. Every `*.zsh` file in that folder is loaded, so new groups of functions can go there as their own file.

| Command | Does |
|---|---|
| `awslogin [profile]` | SSO login (skipped while still valid), sets `AWS_PROFILE` for the shell, logs Docker in to ECR |
| `rds [profile]` | pick an RDS instance or cluster endpoint with fzf |
| `dbAuth <mysql\|postgres> [profile]` | IAM database token for the chosen endpoint, copied to the clipboard (valid 15 minutes) |
Leave out the profile and fzf asks for one. Account-specific values go in `~/.zshrc.local`:

```shell
export ECR_REGISTRY=<account-id>.dkr.ecr.us-east-1.amazonaws.com
export RDS_DB_USER=<iam-database-user>   # defaults to your macOS username
```

Profiles come from `~/.aws/config`; on a new Mac copy it over or run `aws configure sso`.

## tmux

The prefix is `Ctrl-a`: press it, let go, then the key.

| Keys | Does |
|---|---|
| `Ctrl-h` / `j` / `k` / `l` (no prefix) | move between panes and Neovim splits |
| `Alt` + arrows (no prefix) | move between panes |
| `Ctrl-a` `h` / `j` / `k` / `l` | move between panes |
| `Ctrl-a` `\|` or `\` | split side by side |
| `Ctrl-a` `-` or `_` | split top and bottom |
| `Ctrl-a` `Ctrl-h` / `Ctrl-j` / `Ctrl-k` / `Ctrl-l` | resize the pane (repeatable) |
| `Ctrl-a` `x` | close the pane |
| `Ctrl-a` `c` | new window |
| `Shift` + left/right | previous / next window |
| `Ctrl-a` `Space` | last window |
| `Ctrl-a` `@` / `J` | pull a pane in from another window, side by side / stacked |
| `Ctrl-a` `!` | break the pane out into its own window |
| `Ctrl-a` `Ctrl-f` | switch session (fzf) |
| `Ctrl-a` `Ctrl-n` | new named session |
| `Ctrl-a` `Ctrl-y` | lazygit popup |
| `Ctrl-a` `d` | dotfiles menu |
| `Ctrl-a` `r` | reload the config |
| `Ctrl-a` `Shift-i` | install newly added plugins |

The theme follows macOS light/dark mode (Catppuccin latte/mocha) through `theme-light.conf` and `theme-dark.conf`. Plugins live in `~/.config/tmux/plugins` and are gitignored.

## Extras

`extras/` holds configs that are no longer installed by default (yabai, skhd, iTerm, OpenCode, Claude). To link one by hand:

```shell
stow --dir ~/repos/dotfiles/extras --target ~ yabai
```

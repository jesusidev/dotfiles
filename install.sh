#!/usr/bin/env bash
# Provision a Mac from this repo. Safe to re-run: every step checks before acting.
#
#   ./install.sh             do everything
#   ./install.sh --dry-run   print what would happen, change nothing
#   ./install.sh --no-macos  skip macOS system settings
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zshrc git nvim ghostty starship)   # folders in this repo linked into $HOME
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=0
RUN_MACOS=1

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-macos) RUN_MACOS=0 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
run() {
  if (( DRY_RUN )); then printf '    [dry-run] %s\n' "$*"; else "$@"; fi
}

# 1. Xcode command line tools (git, compilers) ---------------------------------
step "Xcode command line tools"
if xcode-select -p >/dev/null 2>&1; then
  info "already installed"
else
  run xcode-select --install
  if (( ! DRY_RUN )); then
    info "finish the installer dialog; waiting..."
    until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  fi
fi

# 2. Homebrew ------------------------------------------------------------------
step "Homebrew"
if [ -x /opt/homebrew/bin/brew ] || command -v brew >/dev/null; then
  info "already installed"
else
  if (( DRY_RUN )); then
    info "[dry-run] install Homebrew from https://brew.sh"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Packages from the Brewfile ------------------------------------------------
step "Brewfile packages"
if command -v brew >/dev/null; then
  run brew bundle --file="$DOTFILES/Brewfile"
else
  info "brew not available yet; would run: brew bundle --file=$DOTFILES/Brewfile"
fi

# 4. Zap (zsh plugin manager) --------------------------------------------------
# Cloned directly instead of the official installer, which rewrites ~/.zshrc.
step "Zap zsh plugin manager"
if [ -f "$HOME/.local/share/zap/zap.zsh" ]; then
  info "already installed"
else
  run git clone --depth 1 -b release-v1 https://github.com/zap-zsh/zap.git "$HOME/.local/share/zap"
fi

# 5. Git identity (kept out of the repo in ~/.gitconfig.local) -----------------
# Runs before linking so values in an existing ~/.gitconfig are carried over.
step "Git identity"
if [ -f "$HOME/.gitconfig.local" ]; then
  info "~/.gitconfig.local exists"
else
  name="$(git config --global user.name 2>/dev/null || true)"
  email="$(git config --global user.email 2>/dev/null || true)"
  if (( ! DRY_RUN )); then
    [ -n "$name" ]  || read -rp "    Git name: " name
    [ -n "$email" ] || read -rp "    Git email: " email
  fi
  info "writing ~/.gitconfig.local (name: ${name:-<prompt>})"
  if (( ! DRY_RUN )); then
    cat > "$HOME/.gitconfig.local" <<EOF
[user]
	name = $name
	email = $email
	signingkey = $HOME/.ssh/id_ed25519.pub
EOF
  fi
fi

if [ -f "$HOME/.ssh/id_ed25519" ]; then
  info "SSH key ~/.ssh/id_ed25519 exists"
else
  email="${email:-$(git config --global user.email 2>/dev/null || echo "")}"
  run ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519"
  info "add it to GitHub (auth + signing):"
  info "  gh auth login && gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication"
  info "  gh ssh-key add ~/.ssh/id_ed25519.pub --type signing"
fi

# 6. Link configs into $HOME with stow -----------------------------------------
# Any real file that would be replaced is moved to ~/.dotfiles-backup/<time>/.
step "Linking configs: ${PACKAGES[*]}"
backup_conflicts() {
  local pkg="$1" rel target
  while IFS= read -r rel; do
    target="$HOME/$rel"
    # skip missing files, symlinks, and files already reached through a linked folder
    if [ -e "$target" ] && [ ! -L "$target" ] && [[ "$(realpath "$target")" != "$DOTFILES"/* ]]; then
      info "backing up ~/$rel"
      run mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
      run mv "$target" "$BACKUP_DIR/$rel"
    fi
  done < <(cd "$DOTFILES/$pkg" && find . -type f ! -name .DS_Store | sed 's|^\./||')
}

if command -v stow >/dev/null; then
  for pkg in "${PACKAGES[@]}"; do
    backup_conflicts "$pkg"
    run stow --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
  done
else
  info "stow not installed yet; skipping (re-run after brew bundle)"
fi

# Old .zshrc sourced ~/private.zsh; the new one sources ~/.zshrc.local.
if [ -f "$HOME/private.zsh" ] && [ ! -e "$HOME/.zshrc.local" ]; then
  run mv "$HOME/private.zsh" "$HOME/.zshrc.local"
fi

# 7. macOS settings ------------------------------------------------------------
if (( RUN_MACOS )); then
  step "macOS settings"
  if (( DRY_RUN )); then info "[dry-run] $DOTFILES/macos.sh"; else "$DOTFILES/macos.sh"; fi
fi

# 8. Folders -------------------------------------------------------------------
[ -d "$HOME/repos" ] || run mkdir -p "$HOME/repos"

step "Done"
info "Open Ghostty, start a new shell (zap installs plugins on first launch),"
info "then run nvim once so LazyVim installs its plugins."

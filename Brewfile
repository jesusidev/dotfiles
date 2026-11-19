# CLI tools the kept configs need (zsh, nvim, ghostty, git, tmux), plus everyday apps.
# Install with: brew bundle --file=~/repos/dotfiles/Brewfile

# Linking configs into $HOME
brew "stow"

# Git / GitHub
brew "git"
brew "gh"

# Shell (zsh + zap plugins + prompt)
brew "starship"     # prompt, configured in starship/
brew "eza"          # used by the zap-zsh/exa plugin and the l/ll/la/tree aliases
brew "fzf"          # history alias, docker pickers, tmux session picker

# tmux and what its plugins need
brew "tmux"
brew "zoxide"                        # t-smart-tmux-session-manager
tap "cormacrelf/tap"
# third-party tap: Homebrew requires an explicit trust; this trusts only this formula
brew "cormacrelf/tap/dark-notify", trusted: true   # tmux-dark-notify (follow macOS light/dark)

# Neovim (LazyVim) and what its plugins call out to
brew "neovim"
brew "tree-sitter"
brew "ripgrep"
brew "fd"
brew "lazygit"
brew "node"         # Mason LSPs, Copilot/Supermaven
brew "go"           # Mason builds gopls, delve, gofumpt, goimports with it
brew "python"       # Mason needs Python >= 3.10 for black, debugpy (macOS ships 3.9)
cask "temurin"      # JDK for jdtls (Java LSP) in nvim/lua/plugins/java.lua

# Terminal + font used in ghostty/config
cask "ghostty"
cask "font-jetbrains-mono"
cask "font-symbols-only-nerd-font"

# Apps. Ones already installed by hand are adopted by Homebrew, not reinstalled.
cask "raycast"            # launcher
cask "presentify"         # screen annotation
cask "cleanshot"          # screenshots (CleanShot X)
cask "jetbrains-toolbox"
cask "obs"
cask "paper-design"       # Paper (paper.design); the "paper" cask is a different wallpaper app
cask "postman"
cask "rancher"            # Rancher Desktop; set its PATH option to Manual, .zshrc adds ~/.rd/bin
cask "routine"            # calendar (routine.co)
cask "sublime-text"

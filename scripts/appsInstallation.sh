#!/usr/bin/env bash

# Homebrew Script for OSX
# To execute: save and `chmod +x ./*.sh` then `./*.sh`
#
echo "------------------------------------"
echo "Adjusting macos system settings..."
echo "------------------------------------"
defaults write com.apple.finder AppleShowAllFiles YES
defaults write com.apple.finder CreateDesktop false
killall Finder
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
defaults write NSGlobalDomain AppleScrollerPagingBehavior -int 1
defaults write com.apple.finder QLEnableTextSelection -bool TRUE
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.Finder FXPreferredViewStyle clmv
defaults write com.apple.dock magnification -bool false
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
defaults write com.apple.Safari ShowFavoritesBar -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari ShowOverlayStatusBar -bool true
defaults write com.apple.dock static-only -bool TRUE 
killall Dock
echo "------------------------------------"
echo "Done adjusting"
echo "------------------------------------"


# Check for Homebrew and install if we don't have it
if ! which brew>/dev/null; then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

installHomeBrewApps() {
  # Dev Tools
  echo "------------------------------------"
  echo "Installing development tools..."
  echo "------------------------------------"
  brew tap homebrew/cask
  brew install stow
  brew install --cask docker
  brew install git
  brew install gh
  brew install --cask github
  brew install --cask iterm2
  brew install --cask visual-studio-code
  brew install neovim

  # Web Tools
  echo "------------------------------------"
  echo "Installing web tools..."
  echo "------------------------------------"
  brew install --cask microsoft-edge
  brew install --cask google-chrome
  brew install httpie
  brew install http-server
  brew install node
  brew install fnm
  brew install --cask ngrok
  brew install pnpm
  brew install --cask postman
  brew install nginx

  # Communication Apps
  echo "------------------------------------"
  echo "Installing communication apps..."
  echo "------------------------------------"
  brew install --cask slack
  brew install --cask zoom 

  # Productivity Apps
  echo "------------------------------------"
  echo "Installing productivity apps..."
  echo "------------------------------------"
  brew install --cask hazeover
  brew install --cask raycast
  brew install --cask akiflow
  brew install --cask figma
  brew install --cask shottr
  brew install --cask gifox
  brew install --cask obsidian
  brew install --cask obs
  brew install --cask appcleaner
  brew install --cask sizzy
  brew install koekeishiya/formulae/yabai
  brew install koekeishiya/formulae/skhd
  brew install tmux
  brew install jesseduffield/lazygit/lazygit
  brew install jesseduffield/lazynpm/lazynpm
  brew install starship

  # DevOps Tools
  echo "------------------------------------"
  echo "Installing devops tools..."
  echo "------------------------------------"
  brew install --cask aws-vault
  brew install awscli
  brew install terraform
  brew install kubectl
  brew install kubectx
  brew install kubens
  brew install k9s
  brew install helm

  # Database Tools
  echo "------------------------------------"
  echo "Installing database tools..."
  echo "------------------------------------"
  brew install --cask tableplus
  brew install --cask robo-3t

  # Fonts
  echo "------------------------------------"
  echo "Installing fonts..."
  echo "------------------------------------"
  brew tap homebrew/cask-fonts
  brew install --cask font-hack-nerd-font
  brew install --cask font-jetbrains-mono-nerd-font

  echo "********** DONE **********"

  return 0
}

configureGit() {
  echo "------------------------------------"
  echo "Configuring git..."
  echo "------------------------------------"
  # git config --global user.name "JG"
  # git config --global user.email "jesus@guzman1.com"
  git config --global push.autoSetupRemote true

      echo "WARNING: not checking for existing SSH keys\!"

    # Use current branch only when doing git push
    git config --global push.default current

    echo "What’s your git name?"
    read GIT_SETUP_NAME
    git config --global user.name $GIT_SETUP_NAME

    echo "What’s your git email?"
    read GIT_SETUP_EMAIL
    git config --global user.email $GIT_SETUP_EMAIL

    echo "Now configuring SSH keys..."
    ssh-keygen -t rsa -C $GIT_SETUP_EMAIL

    echo "Let’s start the ssh-agent..."
    eval "$(ssh-agent -s)"

    echo "Adding SSH key..."
    ssh-add ~/.ssh/id_rsa

    echo "Now copying SSH key to clipboard..."
    pbcopy < ~/.ssh/id_rsa.pub

    # Use the patience algorithm for diffing
    git config --global diff.algorithm patience

    git config --global diff.colorMoved default

  echo "********** DONE **********"

  return 0
}

openAppsFromSite() {
  echo "------------------------------------"
  echo "Opening apps from website..."
  echo "------------------------------------"
  open -a "Microsoft Edge" https://www.dev-box.app/ https://www.corsair.com/us/en/downloads https://www.logitech.com/en-us/video-collaboration/software/logi-tune-software.html https://www.lunarvim.org/docs/installation https://www.zapzsh.org/ https://github.com/jimeh/tmuxifier

  echo "********** DONE **********"

  return 0
}

createRepoDir() {
  echo "-----------------"
  echo "Creating repos directory ~/repos"
  echo "-----------------"
  mkdir ~/repos

  echo "********** DONE **********"

  return 0
}

if which brew>/dev/null; then
  # Installing Homebrew Apps
  echo "------------------------------------"
  echo "Installing Homebrew Apps..."
  echo "------------------------------------"
  installHomeBrewApps "$@"
  wait
  configureGit "$@"
  wait
  openAppsFromSite "$@"
  wait
  createRepoDir "$@"
  wait
  echo "------------------------------------"
  echo "Setup is complete 🎉..."
  echo "------------------------------------"

fi

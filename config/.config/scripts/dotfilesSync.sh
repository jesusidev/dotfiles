#!/usr/bin/env bash

# To execute: save and `chmod +x ./*.sh` then `./*.sh`
#

# Check for Homebrew and install if we don't have it
if ! which brew>/dev/null; then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Checking to see if you have stow installed"
if which stow; then
  echo "Stow is installed"
else
  echo "Stow is not installed, installing stow"
  brew install stow
fi


checkIfDirectoryExists() {
  if [ -d "~/.config/$1" ]; then
    echo "$1 exists"
  else
    echo "$1 does not exist"
  fi
}

loopThroughFiles() {
  for dir in ~/dotfiles/config/.config/*/; do
    # Get the name of the directory only not whole path
    folderName=${dir##*/}
    echo "Stowing $folderName"
    echo "Checking if $dir exists"
    checkIfDirectoryExists $dir
  done
}

loopThroughFiles

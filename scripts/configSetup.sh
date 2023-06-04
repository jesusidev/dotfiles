#!/usr/bin/env bash

function check_file_exists() {
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local file=$1

  if [ -f "$file" ]; then
      echo "File $file exists."
      echo "Backing up $file"
      mv "${file}" "${file}_${timestamp}.bk"
      echo "Using stow for symlinking .zshrc..."
      stow zshrc
  else
      echo "File $file does not exist or is not a regular file."
      echo "Using stow for symlinking .zshrc..."
      stow zshrc
  fi
}

checkIfDirectoryExists() {
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local configDirectory=~/.config/$1
    if [[ "$1" == "scripts" || "$1" == "zshrc" ]]; then
        if [ "$1" == "zshrc" ]; then
          check_file_exists ~/.zshrc
        fi
    else
        if [ -d "$configDirectory" ]; then
        echo "$configDirectory exist"
        echo "Backing up $configDirectory"
        mv "${configDirectory}" "${configDirectory}_${timestamp}.bk"
        echo "Using stow for symlinking $1..."
        stow $1
      else
          echo "$configDirectory does not exist"
          echo "Using stow for symlinking $1..."
          stow $1
      fi
    fi
}

loop_config_directories() {
    local directory=~/.dotfiles

    if [ -d "$directory" ]; then
        for dir in "$directory"/*; do
            if [ -d "$dir" ]; then
	            base=$(basename "$dir")
                echo "Location: $dir"
                echo "Name: $base"
                checkIfDirectoryExists $base
                echo "---"
            fi
        done
    else
        echo "Error: $directory is not a valid directory."
    fi
}

loop_config_directories "$@"
wait
echo "-----------------"
echo "Sourcing tmux & zshrc"
echo "-----------------"

source tmux ~/.config/tmux/tmux.conf
source ~/.zshrc

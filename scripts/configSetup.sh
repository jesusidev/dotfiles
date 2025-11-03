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
		touch ~/.dotfiles/zshrc/private.zsh
		stow zshrc
	fi
}

checkIfDirectoryExists() {
	local timestamp=$(date +"%Y%m%d_%H%M%S")
	local targetDirectory

	# Special cases for non-.config directories
	if [[ "$1" == "scripts" || "$1" == "zshrc" ]]; then
		if [ "$1" == "zshrc" ]; then
			check_file_exists ~/.zshrc
		fi
		return
	elif [ "$1" == "claude" ]; then
		# Claude Code uses ~/.claude instead of ~/.config/claude
		targetDirectory=~/.$1
	else
		# Default: use ~/.config/
		targetDirectory=~/.config/$1
	fi

	# Check and stow
	if [ -d "$targetDirectory" ]; then
		echo "$targetDirectory exist"
		echo "Backing up $targetDirectory"
		mv "${targetDirectory}" "${targetDirectory}_${timestamp}.bk"
		echo "Using stow for symlinking $1..."
		stow $1
	else
		echo "$targetDirectory does not exist"
		echo "Using stow for symlinking $1..."
		stow $1
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

echo "----------------"
echo "Starting Setup"
echo "----------------"
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
wait
loop_config_directories "$@"
wait
echo "-----------------"
echo "Sourcing tmux & zshrc"
echo "-----------------"
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
wait
source tmux ~/.config/tmux/tmux.conf
source ~/.zshrc

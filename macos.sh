#!/usr/bin/env bash
# macOS system preferences. Safe to re-run. Some take effect after logout.
set -euo pipefail

echo "==> Applying macOS settings"

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true          # show hidden files
defaults write com.apple.finder CreateDesktop -bool false             # no desktop icons
defaults write com.apple.finder QLEnableTextSelection -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"   # column view

# Global
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
defaults write NSGlobalDomain AppleScrollerPagingBehavior -int 1
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 14

# Dock
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock static-only -bool true                  # only show running apps

# Safari (sandboxed: these may be ignored unless Terminal has Full Disk Access)
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false 2>/dev/null || true
defaults write com.apple.Safari ShowFavoritesBar -bool true 2>/dev/null || true
defaults write com.apple.Safari IncludeDevelopMenu -bool true 2>/dev/null || true
defaults write com.apple.Safari ShowOverlayStatusBar -bool true 2>/dev/null || true

killall Finder Dock 2>/dev/null || true
echo "==> macOS settings applied (log out and back in for key repeat to take effect)"

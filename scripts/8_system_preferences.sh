#!/bin/bash
#
# System Preferences Script
# Sets common macOS defaults for a clean, developer-friendly environment
#

log "Configuring macOS system preferences..."

if [ "$DRY_RUN" = true ]; then
    log "[DRY RUN] Would set macOS system preferences"
    return 0
fi

if ! $AUTO_YES; then
    if ! prompt "Set recommended macOS defaults (Dock, Finder, trackpad, etc.)?"; then
        log "Skipping system preferences"
        return 0
    fi
fi

# Dock: autohide, magnification, tile sizes
log "Configuring Dock..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock largesize -int 64
success "Dock: autohide, magnification enabled"

# Finder: show extensions, path bar, status bar
log "Configuring Finder..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
success "Finder: extensions, path bar, status bar enabled"

# Trackpad: tap to click, three finger drag
log "Configuring trackpad..."
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
success "Trackpad: tap to click, three finger drag enabled"

# Screenshots: save to Downloads
log "Configuring screenshots..."
defaults write com.apple.screencapture location -string "$HOME/Downloads"
success "Screenshots: saving to ~/Downloads"

# Disable auto-correct
log "Disabling auto-correct..."
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
success "Auto-correct disabled"

# Restart affected apps to apply changes
log "Restarting Dock and Finder to apply changes..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

success "System preferences configured"

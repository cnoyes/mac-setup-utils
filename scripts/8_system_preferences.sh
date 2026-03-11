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

# Dock: autohide, left side, magnification
log "Configuring Dock..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock largesize -int 80
success "Dock: autohide, left side, magnification enabled"

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

# Dark mode
log "Enabling dark mode..."
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
success "Dark mode enabled"

# Night Shift: sunset to sunrise
log "Enabling Night Shift..."
CORE_BRIGHTNESS="/private/var/root/Library/Preferences/com.apple.CoreBrightness.plist"
if [ -f "$CORE_BRIGHTNESS" ]; then
    # Night Shift requires CoreBrightness — schedule sunset to sunrise
    sudo defaults write "$CORE_BRIGHTNESS" CBUser-0 -dict-add CBBlueLightReductionSchedule '{ AutoBlueLightReductionEnabled = 1; AutoBlueLightReductionMode = 1; }'
    success "Night Shift: sunset to sunrise"
else
    warn "Night Shift: could not configure automatically"
    log "Enable manually: System Settings → Displays → Night Shift → Sunset to Sunrise"
fi

# Tailscale: set hostname and enable auto-start
if command -v tailscale &>/dev/null; then
    log "Configuring Tailscale..."
    # Detect machine hostname for Tailscale
    MACHINE_NAME=$(scutil --get LocalHostName 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    if [ -n "$MACHINE_NAME" ]; then
        sudo tailscale set --hostname="$MACHINE_NAME"
        success "Tailscale: hostname set to $MACHINE_NAME"
    fi
    # Enable auto-connect so Tailscale survives sleep/reboot
    sudo tailscale set --auto-update
    success "Tailscale: auto-update enabled"
    log "NOTE: Enable 'Start at Login' in the Tailscale menu bar app"
    log "NOTE: Use 'tailscale login' (not 'tailscale up') to reauthenticate"
else
    warn "Tailscale not installed yet, skipping Tailscale config"
fi

# Restart affected apps to apply changes
log "Restarting Dock and Finder to apply changes..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

success "System preferences configured"

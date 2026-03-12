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

# Dock: set app layout
log "Setting Dock apps..."

# Helper function to add an app to the Dock
add_dock_app() {
    local app_path="$1"
    if [ -d "$app_path" ]; then
        defaults write com.apple.dock persistent-apps -array-add \
            "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file://$app_path/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
    fi
}

# Clear existing dock apps
defaults write com.apple.dock persistent-apps -array

# Base apps (all machines)
add_dock_app "/System/Applications/Launchpad.app"
add_dock_app "/Applications/Firefox.app"
add_dock_app "/System/Applications/Messages.app"
add_dock_app "/System/Applications/Notes.app"
add_dock_app "/Applications/Microsoft Excel.app"
add_dock_app "/Applications/Microsoft Word.app"
add_dock_app "/System/Applications/Calendar.app"
add_dock_app "/System/Applications/Photos.app"
add_dock_app "/System/Applications/FaceTime.app"
add_dock_app "/System/Applications/App Store.app"
add_dock_app "/System/Applications/System Settings.app"
add_dock_app "/Applications/Google Chrome.app"
add_dock_app "/Applications/iTerm.app"

# Workstation extras
if [ "${PROFILE_NAME:-}" = "workstation" ]; then
    add_dock_app "/Applications/RStudio.app"
    add_dock_app "/Applications/Visual Studio Code.app"
fi

success "Dock apps configured"

# Finder: show extensions, path bar, status bar
log "Configuring Finder..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"
success "Finder: extensions, path bar, status bar, list view (alphabetical)"

# Trackpad: tap to click, three finger drag
log "Configuring trackpad..."
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
# macOS 13+: three finger drag is under Accessibility → Pointer Control
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad DragLock -bool false
success "Trackpad: tap to click, three finger drag enabled"
log "NOTE: If three finger drag doesn't work, log out and back in"

# Screenshots: save to Downloads
log "Configuring screenshots..."
defaults write com.apple.screencapture location -string "$HOME/Downloads"
success "Screenshots: saving to ~/Downloads"

# Disable auto-correct
log "Disabling auto-correct..."
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
success "Auto-correct disabled"

# Terminal: close window when shell exits
defaults write com.apple.Terminal ShellExitAction -int 0
success "Terminal: close window on exit"

# Dark mode (auto-switch with sunset/sunrise)
log "Enabling dark mode with auto-switching..."
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true
success "Dark mode enabled (auto-switches with sunset/sunrise)"

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
    log "NOTE: Use 'tailscale login' (not 'tailscale up') to reauthenticate"
else
    warn "Tailscale not installed yet, skipping Tailscale config"
fi

# Login items: apps that should start at login
log "Configuring login items..."
LOGIN_APPS=(
    "/Applications/Google Drive.app"
    "/Applications/Amphetamine.app"
    "/Applications/Tailscale.app"
    "/Applications/Rectangle.app"
)
for app in "${LOGIN_APPS[@]}"; do
    APP_NAME=$(basename "$app" .app)
    if [ -d "$app" ]; then
        osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$app\", hidden:false}" 2>/dev/null || true
        success "$APP_NAME: start at login enabled"
    fi
done

# Browser password management: disable built-in, force Bitwarden extension
log "Configuring browsers to use Bitwarden (disabling built-in password/autofill)..."

# Safari: disable all autofill and password saving
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false
# Disable iCloud Keychain password suggestions in Safari
defaults write com.apple.Safari SuggestPasswords -bool false
defaults write com.apple.Safari PasswordBreachDetectionOn -bool false
success "Safari: autofill and password saving disabled"

# Default browser: Firefox
if [ -d "/Applications/Firefox.app" ]; then
    log "Setting Firefox as default browser..."
    open -a "Firefox" --args -setDefaultBrowser 2>/dev/null || true
    success "Firefox: set as default browser"
fi

# Chrome: disable password manager and autofill, force-install Bitwarden extension
CHROME_MANAGED="/Library/Managed Preferences/com.google.Chrome.plist"
if [ -d "/Applications/Google Chrome.app" ]; then
    sudo mkdir -p "/Library/Managed Preferences"
    sudo defaults write "$CHROME_MANAGED" PasswordManagerEnabled -bool false
    sudo defaults write "$CHROME_MANAGED" AutofillAddressEnabled -bool false
    sudo defaults write "$CHROME_MANAGED" AutofillCreditCardEnabled -bool false
    # Force-install and pin Bitwarden extension
    sudo defaults write "$CHROME_MANAGED" ExtensionSettings -dict \
        "nngceckbapebfimnlniiiahkandclblb" '<dict><key>installation_mode</key><string>force_installed</string><key>update_url</key><string>https://clients2.google.com/service/update2/crx</string><key>toolbar_pin</key><string>force_pinned</string></dict>'
    success "Chrome: autofill disabled, Bitwarden pinned to toolbar"
fi

# Firefox: disable password manager and autofill, install Bitwarden extension
FIREFOX_DIST="/Applications/Firefox.app/Contents/Resources/distribution"
if [ -d "/Applications/Firefox.app" ]; then
    sudo mkdir -p "$FIREFOX_DIST"
    sudo tee "$FIREFOX_DIST/policies.json" > /dev/null << 'POLICY_EOF'
{
  "policies": {
    "OfferToSaveLogins": false,
    "PasswordManagerEnabled": false,
    "DisableFormHistory": true,
    "ExtensionSettings": {
      "{446900e4-71c2-419f-a6a7-df9c091e268b}": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi",
        "default_area": "navbar"
      }
    }
  }
}
POLICY_EOF
    success "Firefox: autofill disabled, Bitwarden extension force-installed"
fi

# Restart affected apps to apply changes
log "Restarting Dock and Finder to apply changes..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

success "System preferences configured"

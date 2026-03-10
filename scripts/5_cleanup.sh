#!/bin/bash
#
# Cleanup Script
# Safely removes unwanted pre-installed macOS applications
#

log "Scanning for unwanted applications..."

# List of common bloatware apps (users can customize this)
UNWANTED_APPS=(
    "GarageBand.app"
    "iMovie.app"
    "Keynote.app"
    "Numbers.app"
    "Pages.app"
)

# Additional removals for thin clients
if [ "${PROFILE_NAME:-}" = "thin-client" ]; then
    UNWANTED_APPS+=(
        "Android Studio.app"
        "Sublime Text.app"
        "RStudio.app"
        "R.app"
    )
fi

# Function to get app size
get_app_size() {
    local app="$1"
    if [ -d "$app" ]; then
        du -sh "$app" 2>/dev/null | awk '{print $1}'
    else
        echo "N/A"
    fi
}

# Find installed unwanted apps
FOUND_APPS=()
TOTAL_SIZE=0

echo ""
echo "Checking for unwanted applications..."
echo ""

for app in "${UNWANTED_APPS[@]}"; do
    APP_PATH="/Applications/$app"
    if [ -d "$APP_PATH" ]; then
        SIZE=$(get_app_size "$APP_PATH")
        echo "  Found: $app ($SIZE)"
        FOUND_APPS+=("$APP_PATH")
    fi
done

if [ ${#FOUND_APPS[@]} -eq 0 ]; then
    success "No unwanted applications found"
    return 0
fi

echo ""
warn "Found ${#FOUND_APPS[@]} unwanted application(s)"
echo ""

if [ "$DRY_RUN" = true ]; then
    log "[DRY RUN] Would prompt to remove the above applications"
    return 0
fi

echo "⚠️  WARNING: This will permanently delete these applications"
echo "   You can reinstall them from the App Store if needed later"
echo ""

if ! prompt "Remove these applications?"; then
    log "Skipping application removal"
    return 0
fi

# Remove each app
for app_path in "${FOUND_APPS[@]}"; do
    APP_NAME=$(basename "$app_path")
    log "Removing $APP_NAME..."

    # Try to remove with sudo (may require password)
    if sudo rm -rf "$app_path" 2>/dev/null; then
        success "Removed $APP_NAME"
    else
        error "Failed to remove $APP_NAME (you may need to remove it manually)"
    fi
done

# Clear Launchpad cache to remove icons
log "Refreshing Launchpad..."
defaults write com.apple.dock ResetLaunchPad -bool true
killall Dock

success "Cleanup complete"

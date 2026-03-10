#!/bin/bash
#
# Passwordless Sudo Script
# Configures NOPASSWD sudo for the current user
#

log "Setting up passwordless sudo..."

if [ "$DRY_RUN" = true ]; then
    log "[DRY RUN] Would configure passwordless sudo for $USER"
    return 0
fi

SUDOERS_FILE="/etc/sudoers.d/$USER"

if [ -f "$SUDOERS_FILE" ]; then
    success "Passwordless sudo already configured"
else
    if ! $AUTO_YES; then
        if ! prompt "Enable passwordless sudo for $USER?"; then
            log "Skipping passwordless sudo"
            return 0
        fi
    fi

    log "Setting up passwordless sudo for $USER..."
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDOERS_FILE" > /dev/null
    sudo chmod 440 "$SUDOERS_FILE"
    success "Passwordless sudo configured"
fi

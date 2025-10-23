#!/bin/bash
#
# Applications Installation Script
# Installs GUI applications via Homebrew Cask
#

log "Installing applications..."

# Read casks from config file
CASKS_FILE="$CONFIG_DIR/brew_casks.txt"

if [ ! -f "$CASKS_FILE" ]; then
    error "Casks config file not found: $CASKS_FILE"
    return 1
fi

# Parse casks (skip comments and empty lines)
CASKS=$(grep -v '^#' "$CASKS_FILE" | grep -v '^$' | tr '\n' ' ')

if [ -z "$CASKS" ]; then
    warn "No casks to install"
    return 0
fi

log "Applications to install:"
echo "$CASKS" | tr ' ' '\n' | sed 's/^/  - /'
echo ""

if [ "$DRY_RUN" = true ]; then
    log "[DRY RUN] Would install the above applications"
    return 0
fi

if ! $AUTO_YES; then
    if ! prompt "Install these applications?"; then
        log "Skipping application installation"
        return 0
    fi
fi

# Install each cask
for cask in $CASKS; do
    if brew list --cask "$cask" &> /dev/null; then
        success "$cask already installed"
    else
        log "Installing $cask..."
        if brew install --cask "$cask"; then
            success "$cask installed"
        else
            error "Failed to install $cask"
        fi
    fi
done

success "Application installation complete"

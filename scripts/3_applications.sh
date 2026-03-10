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

# Install profile-specific casks
if [ -n "${BREW_CASKS_EXTRA:-}" ]; then
    log "Installing profile-specific casks..."
    for cask in $BREW_CASKS_EXTRA; do
        if brew list --cask "$cask" &> /dev/null; then
            success "$cask already installed (profile)"
        else
            log "Installing $cask (profile)..."
            if brew install --cask "$cask"; then
                success "$cask installed"
            else
                error "Failed to install $cask"
            fi
        fi
    done
fi

# Install Mac App Store apps via mas
if ! command -v mas &> /dev/null; then
    log "Installing mas (Mac App Store CLI)..."
    if ! brew install mas; then
        warn "Failed to install mas — install Amphetamine manually from the App Store"
    fi
fi

if command -v mas &> /dev/null; then
    log "Checking Mac App Store apps..."

    # Amphetamine (Mac App Store only, ID: 937984704)
    if mas list | grep -q "937984704"; then
        success "Amphetamine already installed"
    else
        log "Installing Amphetamine from Mac App Store..."
        if mas install 937984704; then
            success "Amphetamine installed"
        else
            warn "Failed to install Amphetamine (you may need to sign in to the App Store first)"
        fi
    fi
fi

success "Application installation complete"

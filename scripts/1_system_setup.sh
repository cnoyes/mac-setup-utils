#!/bin/bash
#
# System Setup Script
# Installs Xcode CLI tools and Homebrew
#

log "Installing system prerequisites..."

# Install Xcode Command Line Tools
if xcode-select -p &> /dev/null; then
    success "Xcode Command Line Tools already installed"
else
    log "Installing Xcode Command Line Tools..."
    if [ "$DRY_RUN" = false ]; then
        xcode-select --install
        # Wait for installation to complete
        until xcode-select -p &> /dev/null; do
            sleep 5
        done
        success "Xcode Command Line Tools installed"
    else
        log "[DRY RUN] Would install Xcode Command Line Tools"
    fi
fi

# Install Homebrew
if command -v brew &> /dev/null; then
    success "Homebrew already installed"
    log "Updating Homebrew..."
    if [ "$DRY_RUN" = false ]; then
        brew update
    fi
else
    log "Installing Homebrew..."
    if [ "$DRY_RUN" = false ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH
        if [[ $(uname -m) == 'arm64' ]]; then
            # Apple Silicon
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Intel
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        success "Homebrew installed"
    else
        log "[DRY RUN] Would install Homebrew"
    fi
fi

# Verify Homebrew
if command -v brew &> /dev/null; then
    BREW_VERSION=$(brew --version | head -n1)
    log "Homebrew version: $BREW_VERSION"
fi

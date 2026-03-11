#!/bin/bash
#
# System Setup Script
# Installs Xcode CLI tools and Homebrew
#

log "Installing system prerequisites..."

# Enable Remote Login (SSH)
if sudo systemsetup -getremotelogin 2>/dev/null | grep -q "Off"; then
    log "Enabling Remote Login (SSH)..."
    if sudo systemsetup -setremotelogin on 2>/dev/null; then
        success "Remote Login (SSH) enabled"
    else
        warn "Could not enable Remote Login automatically (requires Full Disk Access)"
        log "Please enable manually: System Settings → General → Sharing → Remote Login"
        read -p "  Press Enter once Remote Login is enabled..." -r
        if sudo systemsetup -getremotelogin 2>/dev/null | grep -q "On"; then
            success "Remote Login (SSH) confirmed enabled"
        else
            warn "Remote Login still off — enable it later for SSH access"
        fi
    fi
else
    success "Remote Login (SSH) already enabled"
fi

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

    # Fix /usr/local permissions (fresh macOS installs often have root-owned dirs)
    if [ -d /usr/local/share/man ]; then
        log "Fixing /usr/local permissions for Homebrew..."
        sudo chown -R "$(whoami)" /usr/local/share/man
        success "Homebrew directory permissions fixed"
    fi
fi

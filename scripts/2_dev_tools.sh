#!/bin/bash
#
# Development Tools Installation Script
# Installs languages, CLIs, and development utilities
#

log "Installing development tools..."

# Read formulae from config file
FORMULAE_FILE="$CONFIG_DIR/brew_formulae.txt"

if [ ! -f "$FORMULAE_FILE" ]; then
    error "Formulae config file not found: $FORMULAE_FILE"
    return 1
fi

# Parse formulae (skip comments and empty lines)
FORMULAE=$(grep -v '^#' "$FORMULAE_FILE" | grep -v '^$' | tr '\n' ' ')

if [ -z "$FORMULAE" ]; then
    warn "No formulae to install"
    return 0
fi

log "Formulae to install:"
echo "$FORMULAE" | tr ' ' '\n' | sed 's/^/  - /'
echo ""

if [ "$DRY_RUN" = true ]; then
    log "[DRY RUN] Would install the above formulae"
    return 0
fi

if ! $AUTO_YES; then
    if ! prompt "Install these formulae?"; then
        log "Skipping formulae installation"
        return 0
    fi
fi

# Install each formula
for formula in $FORMULAE; do
    if brew list "$formula" &> /dev/null; then
        success "$formula already installed"
    else
        log "Installing $formula..."
        if brew install "$formula"; then
            success "$formula installed"
        else
            error "Failed to install $formula"
        fi
    fi
done

# Install profile-specific formulae
if [ -n "${BREW_FORMULAE_EXTRA:-}" ]; then
    log "Installing profile-specific formulae..."
    for formula in $BREW_FORMULAE_EXTRA; do
        if brew list "$formula" &> /dev/null; then
            success "$formula already installed (profile)"
        else
            log "Installing $formula (profile)..."
            if brew install "$formula"; then
                success "$formula installed"
            else
                error "Failed to install $formula"
            fi
        fi
    done
fi

# Post-installation setup

# Setup pyenv
if command -v pyenv &> /dev/null; then
    log "Setting up pyenv..."

    # Add to shell config if not already there
    if ! grep -q 'pyenv init' ~/.zshrc 2>/dev/null; then
        cat >> ~/.zshrc << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF
        success "Added pyenv to ~/.zshrc"
    fi

    # Load pyenv for this session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)" 2>/dev/null || true
    eval "$(pyenv init -)" 2>/dev/null || true

    # Install latest Python
    if prompt "Install Python 3.13 via pyenv?"; then
        log "Installing Python 3.13..."
        pyenv install 3.13.0 --skip-existing
        pyenv global 3.13.0
        success "Python 3.13 set as global version"
    fi
fi

# Setup nvm (Node Version Manager)
if brew list nvm &> /dev/null; then
    log "Setting up nvm..."

    # Create nvm directory
    mkdir -p ~/.nvm

    # Add to shell config if not already there
    if ! grep -q 'NVM_DIR' ~/.zshrc 2>/dev/null; then
        cat >> ~/.zshrc << 'EOF'

# nvm configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
EOF
        success "Added nvm to ~/.zshrc"
    fi

    # Load nvm for this session (nvm.sh uses uninitialized vars, so disable set -u)
    export NVM_DIR="$HOME/.nvm"
    set +u
    [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"
    set -u

    # Install latest LTS Node
    if command -v nvm &> /dev/null; then
        if prompt "Install Node.js LTS via nvm?"; then
            log "Installing Node.js LTS..."
            nvm install --lts
            nvm use --lts
            nvm alias default 'lts/*'
            success "Node.js LTS installed and set as default"
        fi
    fi
fi

# Install global npm packages
if command -v npm &> /dev/null; then
    NPM_FILE="$CONFIG_DIR/npm_globals.txt"
    if [ -f "$NPM_FILE" ]; then
        NPM_PACKAGES=$(grep -v '^#' "$NPM_FILE" | grep -v '^$' | tr '\n' ' ')
        if [ -n "$NPM_PACKAGES" ]; then
            if prompt "Install global npm packages?"; then
                log "Installing global npm packages..."
                for package in $NPM_PACKAGES; do
                    log "Installing $package..."
                    npm install -g "$package" || warn "Failed to install $package"
                done
            fi
        fi
    fi
fi

success "Development tools installation complete"

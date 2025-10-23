#!/bin/bash
#
# Claude Code Setup Script
# Installs Claude Code and configures integrations
#

log "Setting up Claude Code..."

# Check if Claude Code is already installed
if command -v claude &> /dev/null; then
    success "Claude Code already installed"
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    log "Version: $CLAUDE_VERSION"
else
    log "Claude Code not found"
    echo ""
    echo "To install Claude Code:"
    echo "  1. Visit: https://claude.ai/download"
    echo "  2. Download the installer for macOS"
    echo "  3. Follow the installation instructions"
    echo ""
    if prompt "Open Claude Code download page in browser?"; then
        open "https://claude.ai/download"
    fi
    warn "Please install Claude Code manually and re-run this script"
    return 0
fi

# Setup GitHub CLI authentication (needed for Claude Code integrations)
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        success "GitHub CLI already authenticated"
    else
        log "Authenticating with GitHub..."
        if prompt "Authenticate with GitHub now?"; then
            gh auth login
            success "GitHub authentication complete"
        else
            warn "Skipping GitHub authentication"
        fi
    fi
else
    warn "GitHub CLI not installed, skipping authentication"
fi

# Clone dev-templates repository
TEMPLATES_DIR="$HOME/code/dev-templates"
if [ -d "$TEMPLATES_DIR" ]; then
    success "dev-templates already cloned"
else
    log "Cloning dev-templates repository..."
    if [ -d "$HOME/code" ]; then
        cd "$HOME/code"
    else
        mkdir -p "$HOME/code"
        cd "$HOME/code"
    fi

    if prompt "Clone dev-templates repository now?"; then
        if gh auth status &> /dev/null 2>&1; then
            git clone git@github.com:cnoyes/dev-templates.git
            success "dev-templates cloned to ~/code/dev-templates"
        else
            warn "GitHub not authenticated. You can clone manually later:"
            warn "  cd ~/code && git clone git@github.com:cnoyes/dev-templates.git"
        fi
    fi
fi

# Setup Claude Code configuration directory
CLAUDE_CONFIG_DIR="$HOME/.config/claude-code"
if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
    log "Creating Claude Code config directory..."
    mkdir -p "$CLAUDE_CONFIG_DIR"
fi

# Create example settings file
SETTINGS_FILE="$CLAUDE_CONFIG_DIR/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
    log "Creating example Claude Code settings..."
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "editor": "code",
  "defaultBranch": "main",
  "autoCommit": false,
  "conventionalCommits": true
}
EOF
    success "Created $SETTINGS_FILE"
fi

success "Claude Code setup complete"

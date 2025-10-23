#!/bin/bash
#
# Mac Setup Utils - Main Installation Script
# Automated Mac development environment setup
#
# Usage:
#   ./install.sh              # Interactive mode
#   ./install.sh --yes        # Auto-approve everything
#   ./install.sh --skip-apps  # Skip application installation
#

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
CONFIG_DIR="$SCRIPT_DIR/config"
DOTFILES_DIR="$SCRIPT_DIR"

# State file
STATE_FILE="$HOME/.mac-setup-state.json"

# Flags
AUTO_YES=false
SKIP_APPS=false
DRY_RUN=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --skip-apps)
            SKIP_APPS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Mac Setup Utils - Automated development environment setup"
            echo ""
            echo "Usage: ./install.sh [options]"
            echo ""
            echo "Options:"
            echo "  --yes, -y       Auto-approve all prompts"
            echo "  --skip-apps     Skip application installation"
            echo "  --dry-run       Show what would be installed without installing"
            echo "  --help, -h      Show this help message"
            echo ""
            exit 0
            ;;
    esac
done

# Helper functions
log() {
    echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
}

section() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  $*"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

prompt() {
    if [ "$AUTO_YES" = true ]; then
        return 0
    fi
    read -p "  $1 (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Welcome
clear
echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║              Mac Setup Utils v1.0                          ║
║                                                            ║
║         Automated Development Environment Setup           ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

log "Starting Mac setup..."
log "Script directory: $SCRIPT_DIR"

if [ "$DRY_RUN" = true ]; then
    warn "DRY RUN MODE - No changes will be made"
fi

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion)
log "macOS version: $MACOS_VERSION"

# Confirm before starting
if ! $AUTO_YES; then
    echo ""
    echo "This script will install:"
    echo "  1. Xcode Command Line Tools"
    echo "  2. Homebrew package manager"
    echo "  3. Development tools (Python, R, Node, etc.)"
    echo "  4. Applications (VSCode, browsers, etc.)"
    echo "  5. Claude Code and integrations"
    echo "  6. Dotfiles configuration"
    echo ""
    if ! prompt "Continue with installation?"; then
        log "Installation cancelled"
        exit 0
    fi
fi

# Run setup scripts in order
section "Step 1/6: System Setup"
if [ -f "$SCRIPTS_DIR/1_system_setup.sh" ]; then
    source "$SCRIPTS_DIR/1_system_setup.sh"
else
    error "System setup script not found"
    exit 1
fi

section "Step 2/6: Development Tools"
if [ -f "$SCRIPTS_DIR/2_dev_tools.sh" ]; then
    source "$SCRIPTS_DIR/2_dev_tools.sh"
else
    warn "Development tools script not found, skipping"
fi

section "Step 3/6: Applications"
if [ "$SKIP_APPS" = false ] && [ -f "$SCRIPTS_DIR/3_applications.sh" ]; then
    source "$SCRIPTS_DIR/3_applications.sh"
else
    warn "Skipping applications installation"
fi

section "Step 4/6: Claude Code Setup"
if [ -f "$SCRIPTS_DIR/4_claude_code.sh" ]; then
    source "$SCRIPTS_DIR/4_claude_code.sh"
else
    warn "Claude Code setup script not found, skipping"
fi

section "Step 5/6: Dotfiles"
if [ -f "$SCRIPTS_DIR/6_dotfiles.sh" ]; then
    source "$SCRIPTS_DIR/6_dotfiles.sh"
else
    warn "Dotfiles script not found, skipping"
fi

section "Step 6/6: Cleanup (Optional)"
if prompt "Remove unwanted pre-installed apps?"; then
    if [ -f "$SCRIPTS_DIR/5_cleanup.sh" ]; then
        source "$SCRIPTS_DIR/5_cleanup.sh"
    else
        warn "Cleanup script not found, skipping"
    fi
else
    log "Skipping cleanup"
fi

# Final summary
section "Installation Complete!"

echo -e "${GREEN}✓ Mac setup completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. ${CYAN}Restart your terminal${NC} to load new environment"
echo "  2. ${CYAN}cd ~/code && git clone git@github.com:cnoyes/dev-templates.git${NC}"
echo "  3. ${CYAN}./dev-templates/new-project.sh my-first-project \"Description\"${NC}"
echo ""
echo "Installed tools:"
echo "  - Homebrew: $(command -v brew >/dev/null && echo '✓' || echo '✗')"
echo "  - Git: $(command -v git >/dev/null && echo '✓' || echo '✗')"
echo "  - Python: $(command -v python3 >/dev/null && echo '✓' || echo '✗')"
echo "  - Node: $(command -v node >/dev/null && echo '✓' || echo '✗')"
echo "  - R: $(command -v R >/dev/null && echo '✓' || echo '✗')"
echo "  - GitHub CLI: $(command -v gh >/dev/null && echo '✓' || echo '✗')"
echo ""
echo "Configuration files:"
echo "  - Dotfiles copied to ~/"
echo "  - See ~/.zshrc, ~/.vimrc, ~/.gitconfig"
echo ""
echo -e "${BLUE}Happy coding!${NC}"
echo ""

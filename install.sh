#!/bin/bash
#
# Mac Setup Utils - Main Installation Script
# Automated Mac development environment setup
#
# Usage:
#   ./install.sh                          # Interactive mode
#   ./install.sh --yes                    # Auto-approve everything
#   ./install.sh --skip-apps             # Skip application installation
#   ./install.sh --profile workstation   # Use workstation profile
#   ./install.sh --profile thin-client   # Use thin-client profile
#

set -u  # Exit on undefined variable

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
PROFILES_DIR="$SCRIPT_DIR/profiles"
DOTFILES_DIR="$SCRIPT_DIR"

# State file
STATE_FILE="$HOME/.mac-setup-state.json"

# Flags
AUTO_YES=false
SKIP_APPS=false
DRY_RUN=false
PROFILE_ARG=""

# Profile variables (defaults — overridden by profile)
PROFILE_NAME=""
PROFILE_DESC=""
BREW_FORMULAE_EXTRA=""
BREW_CASKS_EXTRA=""
CLONE_REPOS=false
SETUP_KARA_USER=false
GOOGLE_DRIVE_ACCOUNTS="clay"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
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
        --profile)
            PROFILE_ARG="$2"
            shift 2
            ;;
        --help|-h)
            echo "Mac Setup Utils - Automated development environment setup"
            echo ""
            echo "Usage: ./install.sh [options]"
            echo ""
            echo "Options:"
            echo "  --yes, -y              Auto-approve all prompts"
            echo "  --skip-apps            Skip application installation"
            echo "  --profile <name>       Use a machine profile (workstation, thin-client)"
            echo "  --dry-run              Show what would be installed without installing"
            echo "  --help, -h             Show this help message"
            echo ""
            echo "Profiles:"
            echo "  workstation            Full dev workstation (iMac — pyenv, R, ffmpeg, etc.)"
            echo "  thin-client            Lightweight client (MacBook — SSH to ai-lab/iMac)"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run './install.sh --help' for usage"
            exit 1
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
║              Mac Setup Utils v2.0                          ║
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

# Profile selection
if [ -n "$PROFILE_ARG" ]; then
    # Profile specified via --profile flag
    PROFILE_FILE="$PROFILES_DIR/${PROFILE_ARG}.txt"
    if [ ! -f "$PROFILE_FILE" ]; then
        error "Profile not found: $PROFILE_ARG"
        echo "Available profiles:"
        for p in "$PROFILES_DIR"/*.txt; do
            [ -f "$p" ] && echo "  - $(basename "$p" .txt)"
        done
        exit 1
    fi
    source "$PROFILE_FILE"
    log "Using profile: $PROFILE_NAME ($PROFILE_DESC)"
else
    # Interactive profile selection
    echo ""
    echo "Select a machine profile:"
    echo ""
    echo "  1) ${CYAN}workstation${NC}   — Full dev workstation (iMac)"
    echo "                      pyenv, R, ffmpeg, tmux, RStudio, iTerm, repos"
    echo ""
    echo "  2) ${CYAN}thin-client${NC}   — Lightweight client (MacBook Pro/Air)"
    echo "                      Minimal tools, SSH to ai-lab/iMac for heavy work"
    echo ""
    read -p "  Enter choice (1 or 2): " -n 1 -r PROFILE_CHOICE
    echo ""

    case $PROFILE_CHOICE in
        1)
            source "$PROFILES_DIR/workstation.txt"
            ;;
        2)
            source "$PROFILES_DIR/thin-client.txt"
            ;;
        *)
            error "Invalid choice. Please run again and select 1 or 2."
            exit 1
            ;;
    esac

    log "Using profile: $PROFILE_NAME ($PROFILE_DESC)"
fi

echo ""

# Confirm before starting
TOTAL_STEPS=9
if ! $AUTO_YES; then
    echo ""
    echo "This script will install:"
    echo "  1. Xcode Command Line Tools"
    echo "  2. Homebrew + development tools"
    echo "  3. Applications (GUI apps via Homebrew Cask + Mac App Store)"
    echo "  4. Claude Code and integrations"
    echo "  5. Dotfiles configuration (.zshrc, .vimrc, .gitconfig)"
    echo "  6. Cleanup (remove unwanted apps)"
    echo "  7. SSH keys and config"
    echo "  8. macOS system preferences"
    echo "  9. Passwordless sudo"
    echo ""
    echo "  Profile: ${CYAN}$PROFILE_NAME${NC} ($PROFILE_DESC)"
    if [ -n "$BREW_FORMULAE_EXTRA" ]; then
        echo "  Extra formulae: $BREW_FORMULAE_EXTRA"
    fi
    if [ -n "$BREW_CASKS_EXTRA" ]; then
        echo "  Extra casks: $BREW_CASKS_EXTRA"
    fi
    echo ""
    if ! prompt "Continue with installation?"; then
        log "Installation cancelled"
        exit 0
    fi
fi

# Run setup scripts in order
section "Step 1/$TOTAL_STEPS: System Setup"
if [ -f "$SCRIPTS_DIR/1_system_setup.sh" ]; then
    source "$SCRIPTS_DIR/1_system_setup.sh"
else
    error "System setup script not found"
    exit 1
fi

section "Step 2/$TOTAL_STEPS: Development Tools"
if [ -f "$SCRIPTS_DIR/2_dev_tools.sh" ]; then
    source "$SCRIPTS_DIR/2_dev_tools.sh"
else
    warn "Development tools script not found, skipping"
fi

section "Step 3/$TOTAL_STEPS: Applications"
if [ "$SKIP_APPS" = false ] && [ -f "$SCRIPTS_DIR/3_applications.sh" ]; then
    source "$SCRIPTS_DIR/3_applications.sh"
else
    warn "Skipping applications installation"
fi

section "Step 4/$TOTAL_STEPS: Claude Code Setup"
if [ -f "$SCRIPTS_DIR/4_claude_code.sh" ]; then
    source "$SCRIPTS_DIR/4_claude_code.sh"
else
    warn "Claude Code setup script not found, skipping"
fi

section "Step 5/$TOTAL_STEPS: Dotfiles"
if [ -f "$SCRIPTS_DIR/6_dotfiles.sh" ]; then
    source "$SCRIPTS_DIR/6_dotfiles.sh"
else
    warn "Dotfiles script not found, skipping"
fi

section "Step 6/$TOTAL_STEPS: Cleanup (Optional)"
if prompt "Remove unwanted pre-installed apps?"; then
    if [ -f "$SCRIPTS_DIR/5_cleanup.sh" ]; then
        source "$SCRIPTS_DIR/5_cleanup.sh"
    else
        warn "Cleanup script not found, skipping"
    fi
else
    log "Skipping cleanup"
fi

section "Step 7/$TOTAL_STEPS: SSH Setup"
if [ -f "$SCRIPTS_DIR/7_ssh_setup.sh" ]; then
    source "$SCRIPTS_DIR/7_ssh_setup.sh"
else
    warn "SSH setup script not found, skipping"
fi

section "Step 8/$TOTAL_STEPS: System Preferences"
if [ -f "$SCRIPTS_DIR/8_system_preferences.sh" ]; then
    source "$SCRIPTS_DIR/8_system_preferences.sh"
else
    warn "System preferences script not found, skipping"
fi

section "Step 9/$TOTAL_STEPS: Passwordless Sudo"
if [ -f "$SCRIPTS_DIR/9_passwordless_sudo.sh" ]; then
    source "$SCRIPTS_DIR/9_passwordless_sudo.sh"
else
    warn "Passwordless sudo script not found, skipping"
fi

# Final summary
section "Installation Complete!"

echo -e "${GREEN}✓ Mac setup completed successfully!${NC}"
echo ""
echo "Profile: ${CYAN}$PROFILE_NAME${NC} ($PROFILE_DESC)"
echo ""
echo "Next steps:"
echo "  1. ${CYAN}Restart your terminal${NC} to load new environment"
if [ "$CLONE_REPOS" = true ]; then
    echo "  2. ${CYAN}cd ~/code && git clone git@github.com:cnoyes/dev-templates.git${NC}"
    echo "  3. ${CYAN}./dev-templates/new-project.sh my-first-project \"Description\"${NC}"
fi
echo ""
echo "Installed tools:"
echo "  - Homebrew: $(command -v brew >/dev/null && echo '✓' || echo '✗')"
echo "  - Git: $(command -v git >/dev/null && echo '✓' || echo '✗')"
echo "  - Python: $(command -v python3 >/dev/null && echo '✓' || echo '✗')"
echo "  - Node: $(command -v node >/dev/null && echo '✓' || echo '✗')"
if [ "$PROFILE_NAME" = "workstation" ]; then
    echo "  - R: $(command -v R >/dev/null && echo '✓' || echo '✗')"
    echo "  - pyenv: $(command -v pyenv >/dev/null && echo '✓' || echo '✗')"
    echo "  - ffmpeg: $(command -v ffmpeg >/dev/null && echo '✓' || echo '✗')"
    echo "  - tmux: $(command -v tmux >/dev/null && echo '✓' || echo '✗')"
fi
echo "  - GitHub CLI: $(command -v gh >/dev/null && echo '✓' || echo '✗')"
echo "  - Claude Code: $(command -v claude >/dev/null && echo '✓' || echo '✗')"
echo ""
echo "Configuration files:"
echo "  - Dotfiles copied to ~/"
echo "  - See ~/.zshrc, ~/.vimrc, ~/.gitconfig"
echo "  - SSH config at ~/.ssh/config"
echo ""
echo -e "${BLUE}Happy coding!${NC}"
echo ""

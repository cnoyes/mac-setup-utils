#!/bin/bash
#
# Dotfiles Setup Script
# Copies dotfiles configuration to home directory
#

log "Setting up dotfiles..."

# List of dotfiles to copy
DOTFILES=(
    ".zshrc"
    ".zprofile"
    ".vimrc"
    ".gitconfig"
)

if [ "$DRY_RUN" = true ]; then
    log "[DRY RUN] Would copy dotfiles to home directory"
    return 0
fi

# Backup existing dotfiles
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

for dotfile in "${DOTFILES[@]}"; do
    SOURCE="$DOTFILES_DIR/$dotfile"
    DEST="$HOME/$dotfile"

    if [ ! -f "$SOURCE" ]; then
        warn "$dotfile not found in $DOTFILES_DIR, skipping"
        continue
    fi

    # Backup existing file
    if [ -f "$DEST" ]; then
        if [ ! -d "$BACKUP_DIR" ]; then
            mkdir -p "$BACKUP_DIR"
            log "Created backup directory: $BACKUP_DIR"
        fi
        cp "$DEST" "$BACKUP_DIR/$dotfile"
        log "Backed up existing $dotfile"
    fi

    # Copy new dotfile
    cp "$SOURCE" "$DEST"
    success "Copied $dotfile to ~/"
done

# Create or update .gitconfig
if [ ! -f "$HOME/.gitconfig" ]; then
    log "Creating .gitconfig..."
    cat > "$HOME/.gitconfig" << 'EOF'
[user]
    name = Clay Noyes
    email = noyes.clay@gmail.com

[core]
    editor = vim
    autocrlf = input

[init]
    defaultBranch = main

[pull]
    rebase = false

[push]
    default = current
    autoSetupRemote = true

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    lg = log --oneline --graph --all --decorate
EOF
    success "Created ~/.gitconfig"
else
    # Ensure user.name and user.email are set
    if ! git config --global user.name &> /dev/null; then
        git config --global user.name "Clay Noyes"
        success "Set git user.name"
    fi
    if ! git config --global user.email &> /dev/null; then
        git config --global user.email "noyes.clay@gmail.com"
        success "Set git user.email"
    fi
    success ".gitconfig already exists (verified user.name and user.email)"
fi

if [ -d "$BACKUP_DIR" ]; then
    log "Previous dotfiles backed up to: $BACKUP_DIR"
fi

success "Dotfiles setup complete"

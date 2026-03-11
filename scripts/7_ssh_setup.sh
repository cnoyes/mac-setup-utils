#!/bin/bash
#
# SSH Setup Script
# Generates SSH key and configures SSH hosts for all machines
#

log "Setting up SSH..."

SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"
CONFIG_FILE="$SSH_DIR/config"

if [ "$DRY_RUN" = true ]; then
    log "[DRY RUN] Would set up SSH key and config"
    return 0
fi

# Create .ssh directory if needed
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    log "Created $SSH_DIR"
fi

# Generate SSH key if not exists
if [ -f "$KEY_FILE" ]; then
    success "SSH key already exists: $KEY_FILE"
else
    log "Generating ed25519 SSH key..."
    ssh-keygen -t ed25519 -C "noyes.clay@gmail.com" -f "$KEY_FILE" -N ""
    success "SSH key generated: $KEY_FILE"
    echo ""
    log "Public key (add to GitHub and other machines):"
    cat "${KEY_FILE}.pub"
    echo ""
fi

# Create SSH config if it doesn't exist (back up existing)
if [ -f "$CONFIG_FILE" ]; then
    success "SSH config already exists: $CONFIG_FILE"
    log "Review existing config and update manually if needed"
else
    log "Creating SSH config..."
    cat > "$CONFIG_FILE" << 'EOF'
Host ai-lab
    HostName ai-lab
    User clay

Host imac
    HostName imac
    User clay

Host macbook-pro
    HostName macbook-pro
    User clay

Host macbook-air
    HostName macbook-air
    User clay

Host *
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
EOF
    chmod 600 "$CONFIG_FILE"
    success "SSH config created: $CONFIG_FILE"
fi

# Copy SSH key to other machines
log "Distributing SSH key to other machines..."
log "This allows passwordless SSH between your machines."
HOSTS=("ai-lab" "imac" "macbook-pro" "macbook-air")
CURRENT_HOST=$(scutil --get LocalHostName 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
for host in "${HOSTS[@]}"; do
    if [ "$host" = "$CURRENT_HOST" ]; then
        continue
    fi
    if prompt "Copy SSH key to $host?"; then
        ssh-copy-id -i "$KEY_FILE" "clay@$host" || warn "Could not copy key to $host (is it online?)"
    fi
done

success "SSH setup complete"

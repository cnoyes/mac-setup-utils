# === Base config (all machines) ===

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"

# Aliases
alias python="python3"
alias pip="pip3"

# Editor
export VISUAL=vim
export EDITOR="$VISUAL"

# Prompt
export PROMPT='%n@%m %1~ %# '

# Colors
export CLICOLOR=1

# Shell plugins
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

# === Workstation extras (only if pyenv exists) ===
if command -v pyenv &>/dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

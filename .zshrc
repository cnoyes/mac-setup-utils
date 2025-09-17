# Minimal .zshrc for Python and Data Science

# Load pyenv and virtualenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Aliases
alias python="python3"
alias pip="pip3"
alias jn="jupyter notebook"
alias jl="jupyter lab"

# Prompt (optional: clean & informative)
export PROMPT='%n@%m %1~ %# '

# Editor
export EDITOR="code --wait"

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable color for ls
export CLICOLOR=1
export NVM_DIR="$HOME/.nvm"
source "$(brew --prefix nvm)/nvm.sh"
export VISUAL=vim
export EDITOR="$VISUAL"

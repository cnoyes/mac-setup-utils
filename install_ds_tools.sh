#!/bin/zsh

# Install Xcode CLI tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to path
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install data science tools
brew install git
brew install --cask visual-studio-code
brew install --cask rstudio
brew install pyenv
brew install r

# Optional: set global Python version
pyenv install 3.11.8
pyenv global 3.11.8


# mac-setup-utils

**Automated Mac development environment setup for rapid onboarding.**

One script to set up your entire Mac development environment with all your favorite tools, applications, and configurations.

## Quick Start

```bash
# On a brand new Mac:
git clone https://github.com/cnoyes/mac-setup-utils.git
cd mac-setup-utils
./install.sh
```

That's it! In 15-30 minutes you'll have a fully configured development machine.

---

## Table of Contents

- [What This Does](#what-this-does)
- [What Gets Installed](#what-gets-installed)
- [Installation](#installation)
- [Usage](#usage)
- [Customization](#customization)
- [What Each Script Does](#what-each-script-does)
- [Troubleshooting](#troubleshooting)
- [Philosophy](#philosophy)

---

## What This Does

This automated setup script:

1. ✅ **Installs Xcode CLI tools** - Required for development on Mac
2. ✅ **Installs Homebrew** - Package manager for macOS
3. ✅ **Installs development tools** - Python, R, Node, Git, etc.
4. ✅ **Installs applications** - VSCode, browsers, Docker, etc.
5. ✅ **Sets up Claude Code** - AI coding assistant with GitHub integration
6. ✅ **Configures dotfiles** - Shell, vim, git configurations
7. ✅ **Removes bloatware** (optional) - GarageBand, iMovie, etc.
8. ✅ **Clones dev-templates** - Project scaffolding tools

**Time saved:** 2-4 hours of manual setup

**Consistency:** Same environment on every Mac

**Idempotent:** Safe to run multiple times

---

## What Gets Installed

### Core Tools (Always)
- **Xcode Command Line Tools** - Compilers and build tools
- **Homebrew** - Package manager for macOS
- **Git** - Version control
- **GitHub CLI (gh)** - GitHub command line interface

### Development Languages
- **Python 3.13** (via pyenv)
- **Node.js LTS** (via nvm)
- **R** (latest version)

### Command Line Tools
- pyenv & pyenv-virtualenv (Python version management)
- nvm (Node version management)
- zsh-autosuggestions
- zsh-syntax-highlighting
- tree, wget, curl, jq

### Applications (Configurable)
- **Visual Studio Code** - Code editor
- Google Chrome, Firefox (optional)
- RStudio (optional)
- Docker Desktop (optional)
- And more (see `config/brew_casks.txt`)

### Claude Code Integration
- Claude Code CLI (manual install guidance)
- GitHub authentication setup
- dev-templates repository clone

---

## Installation

### Prerequisites

- **macOS** - Tested on macOS 12+ (Monterey and later)
- **Internet connection** - For downloading packages
- **Administrator access** - For installing system tools

### Initial Setup

On a brand new Mac, open Terminal and run:

```bash
# Create code directory
mkdir -p ~/code
cd ~/code

# Clone this repository
git clone https://github.com/cnoyes/mac-setup-utils.git
cd mac-setup-utils

# Run installation
./install.sh
```

The script will prompt you before each major step.

---

## Usage

### Interactive Mode (Recommended)

```bash
./install.sh
```

Prompts you before each step. Safe for first-time use.

### Automatic Mode

```bash
./install.sh --yes
```

Auto-approves all prompts. Good for automated setups.

### Dry Run

```bash
./install.sh --dry-run
```

Shows what would be installed without making changes.

### Skip Applications

```bash
./install.sh --skip-apps
```

Installs dev tools but skips GUI applications.

### Help

```bash
./install.sh --help
```

Shows all available options.

---

## Customization

### Adding/Removing Brew Formulae

Edit `config/brew_formulae.txt`:

```bash
# config/brew_formulae.txt

# Core tools
git
gh

# Add your tools here
postgresql
redis
nginx

# Comment out what you don't need
# imagemagick
```

### Adding/Removing Applications

Edit `config/brew_casks.txt`:

```bash
# config/brew_casks.txt

visual-studio-code

# Add applications you want
google-chrome
firefox
docker-desktop
notion
spotify

# Comment out what you don't need
# slack
```

### Adding Global npm Packages

Edit `config/npm_globals.txt`:

```bash
# config/npm_globals.txt

# yarn
# prettier
# eslint
# @anthropic-ai/claude-code
```

### Customizing Dotfiles

The following dotfiles are included:
- `.zshrc` - Shell configuration
- `.zprofile` - Login shell configuration
- `.vimrc` - Vim editor configuration
- `.gitconfig` - Git configuration (generated interactively)

**To customize:**
1. Edit files in this directory
2. Re-run `./install.sh` (backs up existing files automatically)

---

## What Each Script Does

### `install.sh` (Main Orchestrator)
- Displays welcome screen
- Runs subscripts in order
- Handles errors gracefully
- Shows final summary

### `scripts/1_system_setup.sh`
- Installs Xcode Command Line Tools
- Installs Homebrew
- Adds Homebrew to PATH

### `scripts/2_dev_tools.sh`
- Installs brew formulae from `config/brew_formulae.txt`
- Sets up pyenv with Python 3.13
- Sets up nvm with Node.js LTS
- Installs global npm packages

### `scripts/3_applications.sh`
- Installs GUI applications from `config/brew_casks.txt`
- Uses Homebrew Cask

### `scripts/4_claude_code.sh`
- Guides Claude Code installation
- Authenticates GitHub CLI
- Clones dev-templates repository
- Creates Claude Code config directory

### `scripts/5_cleanup.sh`
- Lists unwanted pre-installed apps
- Prompts for confirmation before removal
- Safely removes bloatware (GarageBand, iMovie, etc.)
- Refreshes Launchpad

### `scripts/6_dotfiles.sh`
- Backs up existing dotfiles
- Copies new dotfiles to ~/
- Creates .gitconfig interactively
- Reports backup location

---

## Troubleshooting

### "xcode-select: command not found"

You're on a very fresh Mac. Run:
```bash
xcode-select --install
```
Then restart the script.

### "brew: command not found" after installation

Restart your terminal or run:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
# OR
eval "$(/usr/local/bin/brew shellenv)"     # Intel
```

### pyenv or nvm not working

Restart your terminal to load the new shell configuration, or run:
```bash
source ~/.zshrc
```

### Permission denied errors

Some operations require sudo (like removing system apps). The script will prompt for your password when needed.

### Script hangs during Xcode installation

The Xcode CLI tools installation may open a dialog box. Complete the installation dialog and the script will continue automatically.

### Want to run only one section?

You can source individual scripts:
```bash
cd mac-setup-utils
source scripts/2_dev_tools.sh
```

---

## After Installation

### 1. Restart Terminal

```bash
# Close and reopen Terminal to load new configurations
```

### 2. Verify Installation

```bash
brew --version
git --version
python --version
node --version
R --version
gh --version
```

### 3. Set up dev-templates

```bash
cd ~/code/dev-templates
./new-project.sh my-first-project "My first project"
```

### 4. Configure Applications

- **VSCode**: Install extensions, sync settings
- **Git**: Configured via .gitconfig
- **GitHub**: Already authenticated via `gh`

---

## Philosophy

### Goals

1. **Zero to productive in minimal time**
2. **Reproducible environments** across machines
3. **Declarative configuration** via text files
4. **Safe and idempotent** - run anytime without fear
5. **Transparent** - show what's happening, no magic

### Design Principles

- **Modular scripts** - Each script has one job
- **Configuration over code** - Edit txt files, not shell scripts
- **Interactive by default** - Prompt before destructive actions
- **Fail gracefully** - One failure doesn't stop everything
- **Document everything** - Clear logs and output

---

## Maintenance

### Updating Installed Tools

```bash
brew update
brew upgrade
brew upgrade --cask
```

### Re-running Setup

The script is idempotent. Run it again to:
- Install newly added formulae/casks
- Update dotfiles
- Verify everything is still installed

```bash
./install.sh
```

### Keeping Scripts Updated

```bash
cd ~/code/mac-setup-utils
git pull origin main
```

---

## Related Projects

- **[dev-templates](https://github.com/cnoyes/dev-templates)** - Project scaffolding with Claude Code integration

---

## Contributing

This is a personal setup repository, but feel free to:
- Fork it for your own use
- Submit issues for bugs
- Share improvements via PR

---

## License

MIT

---

## FAQ

**Q: Will this work on my Intel Mac?**
A: Yes! The script detects your architecture and adjusts accordingly.

**Q: Can I use this with an existing Mac?**
A: Yes! It's safe to run on an existing system. It will skip already-installed tools.

**Q: What if I don't want some of the applications?**
A: Edit `config/brew_casks.txt` and comment out (add `#`) the ones you don't want.

**Q: Can I add my own custom scripts?**
A: Yes! Add them to the `scripts/` directory and source them in `install.sh`.

**Q: Where are dotfiles backed up?**
A: `~/.dotfiles_backup_YYYYMMDD_HHMMSS/`

**Q: Is this secure?**
A: Review all scripts before running. Everything is open source and visible.

---

**Created by Clay Noyes | Powered by Claude Code**

**Last Updated:** October 2024

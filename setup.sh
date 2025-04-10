#!/bin/bash

echo "🚀 Installing Jose's Dev Stack..."

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
  echo "🧪 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Core CLI tools
brew install bat ripgrep fzf gh direnv just exa tokei jq glow dog hyperfine \
             dive trivy go zoxide zsh-autosuggestions zsh-syntax-highlighting \
             semgrep lazydocker

# Docker & Docker Compose (requires Docker Desktop installed manually)
brew install --cask docker
brew install docker-compose

# fzf setup
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

# Rust setup
brew install rustup-init
rustup-init -y
source $HOME/.cargo/env
rustup component add clippy rustfmt
cargo install cargo-edit cargo-generate cargo-nextest

# Golang linting
brew install golangci-lint

# Node + pnpm via Volta
if ! command -v volta &>/dev/null; then
  curl https://get.volta.sh | bash
  source ~/.zshrc
fi
volta install node@latest
VOLTA_FEATURE_PNPM=1 volta install pnpm@latest
volta pin node pnpm

# Global Node CLIs for dev tooling
pnpm add -g zx npm-check-updates @biomejs/biome vitest @playwright/test workbox-cli @lhci/cli

# Optional Tools (comment/uncomment as needed)
# brew install bun
# brew install pkgx
# brew install act

# Shell enhancements
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
echo 'source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
echo 'source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc

echo "✅ Setup complete. Restart terminal or run 'source ~/.zshrc' to activate your new dev environment."


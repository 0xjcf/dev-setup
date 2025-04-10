#!/bin/bash

set -e

step() {
  echo -e "\n🔄 [$1/${TOTAL_STEPS}] $2..."
}

TOTAL_STEPS=13
CURRENT_STEP=1

echo "🚀 Installing Jose's Dev Stack..."

# 1. Homebrew
if command -v brew &>/dev/null; then
  echo "✅ [$CURRENT_STEP/$TOTAL_STEPS] Homebrew already installed"
else
  echo "🔄 [$CURRENT_STEP/$TOTAL_STEPS] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
((CURRENT_STEP++))

# 2. CLI Tools
step $CURRENT_STEP "Installing CLI tools with Homebrew"
cli_tools=(bat ripgrep fzf gh direnv just eza tokei jq glow hyperfine dive trivy go zoxide zsh-autosuggestions zsh-syntax-highlighting semgrep lazydocker pkgconf openssl@3)
for tool in "${cli_tools[@]}"; do
  if brew list "$tool" &>/dev/null || brew list --cask "$tool" &>/dev/null; then
    echo "✅ $tool already installed"
  else
    brew install "$tool"
  fi
done
((CURRENT_STEP++))

# 3. Docker
step $CURRENT_STEP "Installing Docker & Docker Compose"
if brew list --cask docker &>/dev/null; then
  echo "✅ Docker already installed"
else
  brew install --cask docker
fi
if brew list docker-compose &>/dev/null; then
  echo "✅ docker-compose already installed"
else
  brew install docker-compose
fi
if [ ! -d "/Applications/Docker.app" ] && ! pgrep -xq "Docker"; then
  echo "❌ Docker Desktop not found. Consider installing Colima for headless Docker usage:"
  echo "🔧 brew install colima && colima start"
fi
((CURRENT_STEP++))

# 4. Docker Compose plugin config
step $CURRENT_STEP "Updating Docker Compose plugin config"
mkdir -p ~/.docker
DOCKER_CONFIG_FILE=~/.docker/config.json
if ! grep -q cliPluginsExtraDirs "$DOCKER_CONFIG_FILE" 2>/dev/null; then
  echo '{"cliPluginsExtraDirs": ["/opt/homebrew/lib/docker/cli-plugins"]}' > "$DOCKER_CONFIG_FILE"
fi
((CURRENT_STEP++))

# 5. fzf integration
step $CURRENT_STEP "Installing fzf shell integration"
FZF_ZSH_LINE='[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'
FZF_BASH_LINE='[ -f ~/.fzf.bash ] && source ~/.fzf.bash'

if grep -Fxq "$FZF_ZSH_LINE" ~/.zshrc 2>/dev/null && grep -Fxq "$FZF_BASH_LINE" ~/.bashrc 2>/dev/null; then
  echo "✅ fzf shell integration already configured"
else
  FZF_INSTALL="$(brew --prefix)/opt/fzf/install"
  if [ -f "$FZF_INSTALL" ]; then
    "$FZF_INSTALL" --key-bindings --completion --no-update-rc >/dev/null
    echo "✅ fzf shell integration installed"
  else
    echo "⚠️ fzf install script not found at $FZF_INSTALL"
  fi
fi
((CURRENT_STEP++))


# 6. rustup
step $CURRENT_STEP "Installing rustup (if needed)"
if brew list rustup-init &>/dev/null; then
  echo "✅ rustup already installed"
else
  brew install rustup-init
fi
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
if ! command -v rustc &>/dev/null || ! command -v cargo &>/dev/null; then
  rustup-init -y
  source "$HOME/.cargo/env"
fi
((CURRENT_STEP++))

# 7. Cargo env
step $CURRENT_STEP "Sourcing .cargo/env in .zshrc (if missing)"
if ! grep -q 'source \$HOME/.cargo/env' ~/.zshrc 2>/dev/null; then
  echo 'source "$HOME/.cargo/env"' >> ~/.zshrc
fi
((CURRENT_STEP++))

# 8. rustfmt + clippy
step $CURRENT_STEP "Installing rustfmt + clippy"
if rustup component list --installed | grep -q clippy && rustup component list --installed | grep -q rustfmt; then
  echo "✅ rustfmt and clippy components are ready"
else
  rustup component add clippy rustfmt
  echo "✅ rustfmt and clippy components installed"
fi
((CURRENT_STEP++))

# 9. cargo-edit + cargo-nextest
step $CURRENT_STEP "Installing cargo-edit + cargo-nextest"
if command -v cargo-add &>/dev/null; then
  echo "✅ cargo-edit already installed"
else
  cargo install cargo-edit
fi
if command -v cargo-nextest &>/dev/null; then
  echo "✅ cargo-nextest already installed"
else
  cargo install cargo-nextest
fi
((CURRENT_STEP++))

# 10. OpenSSL env vars
step $CURRENT_STEP "Exporting OpenSSL env vars in .zshrc (if missing)"
if ! grep -q 'export OPENSSL_DIR=' ~/.zshrc 2>/dev/null; then
  OPENSSL_PREFIX=$(brew --prefix openssl@3)
  {
    echo 'export OPENSSL_DIR="'$OPENSSL_PREFIX'"'
    echo 'export OPENSSL_INCLUDE_DIR="$OPENSSL_DIR/include"'
    echo 'export OPENSSL_LIB_DIR="$OPENSSL_DIR/lib"'
  } >> ~/.zshrc
fi
((CURRENT_STEP++))

# 11. Volta
step $CURRENT_STEP "Installing Volta (if missing)"
if ! command -v volta &>/dev/null; then
  curl https://get.volta.sh | bash
  source ~/.zshrc
else
  echo "✅ Volta already installed"
fi
((CURRENT_STEP++))

# 12. Node + pnpm via Volta
step $CURRENT_STEP "Installing Node.js + pnpm via Volta"
if volta list node | grep -q 'node'; then
  echo "✅ Node.js already installed via Volta"
else
  volta install node@latest
fi
if volta list pnpm | grep -q 'pnpm'; then
  echo "✅ pnpm already installed via Volta"
else
  VOLTA_FEATURE_PNPM=1 volta install pnpm@latest
fi
((CURRENT_STEP++))

# 13. Final check
step $CURRENT_STEP "Running healthcheck"
./healthcheck.sh --json
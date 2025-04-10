# dev-setup/justfile
# Task automation for your full stack + AI development environment

set shell := ["zsh", "-cu"]

# Global system setup (macOS)
setup:
  echo "🛠 Running system-level setup..."
  ./setup.sh

# Project-level bootstrapping (run this from inside a project directory)
bootstrap:
  echo "🚀 Bootstrapping project in $(pwd)"
  ../dev-setup/bootstrap.sh

# Preview tool documentation for agents
ai-docs:
  bat ../dev-setup/.cursor/tools.mdc

# Open dev-setup docs in glow (Markdown viewer)
view-readme:
  glow README.md

# Run Playwright install (if config exists)
install-playwright:
  if [ -f playwright.config.ts ] || [ -f playwright.config.js ]; then npx playwright install; else echo "🎭 No Playwright config found."; fi


#!/bin/bash

# Use this in each project to ensure local environment consistency

set -e

PROJECT_NAME=$(basename $(pwd))
echo "🔧 Bootstrapping project: $PROJECT_NAME"

# Ensure direnv is trusted
if [ -f .envrc ]; then
  echo "⚙️  Loading .envrc with direnv..."
  direnv allow
fi

# Ensure Volta is managing Node.js and pnpm
VOLTA_FEATURE_PNPM=1 volta install node@20 pnpm@8.6.3
volta pin node@20 pnpm@8.6.3

# Install dependencies
if [ -f pnpm-lock.yaml ]; then
  echo "📦 Installing pnpm dependencies..."
  pnpm install
fi

# Install Playwright browsers if needed
if [ -f playwright.config.ts ] || [ -f playwright.config.js ]; then
  echo "🎭 Installing Playwright browsers..."
  npx playwright install
fi

# Install project-level dev tools
echo "🧪 Installing project dev CLIs..."
pnpm add -D \
  vitest \
  @playwright/test \
  biome \
  workbox-cli \
  @lhci/cli \
  npm-check-updates

# Setup Rust environment
if [ -f Cargo.toml ]; then
  echo "🦀 Checking Rust toolchain..."
  rustup component add clippy rustfmt || true
  cargo check
fi

# Show confirmation
echo "✅ $PROJECT_NAME is now bootstrapped and ready!"


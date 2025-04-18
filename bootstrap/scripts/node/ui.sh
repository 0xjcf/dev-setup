#!/bin/bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Source core modules
source "$SCRIPT_DIR/core/logging.sh"

# Load UI configuration
UI_CONFIG="$SCRIPT_DIR/config/node/ui.json"

# Setup Next.js UI project
setup_node_ui_next() {
  local project_dir=$1
  local project_name=$(basename "$project_dir")

  section "Setting up Node.js UI project (Next.js): $project_name"

  cd "$project_dir" || exit 1

  info "Creating Next.js project..."
  pnpm create next-app . --ts --tailwind --eslint --app --src-dir --import-alias "@/*" --no-git

  info "Installing common development dependencies..."
  local common_deps
  common_deps=$(jq -r '.common.devDependencies | to_entries | map("@\(.key)@\(.value)") | join(" ")' "$UI_CONFIG")
  pnpm add -D $common_deps

  info "Installing Next.js specific development dependencies..."
  local next_deps
  next_deps=$(jq -r '.next.devDependencies | to_entries | map("@\(.key)@\(.value)") | join(" ")' "$UI_CONFIG")
  pnpm add -D $next_deps

  info "Setting up test environment..."
  mkdir -p test
  local files
  files=$(jq -r '.next.structure.files | to_entries[] | "\(.key) \(.value)"' "$UI_CONFIG")
  while read -r file content; do
    echo "$content" > "$file"
  done <<< "$files"

  info "Updating package.json scripts..."
  local scripts
  scripts=$(jq -r '.common.scripts' "$UI_CONFIG")
  jq --argjson scripts "$scripts" '.scripts *= $scripts' package.json > package.json.tmp
  mv package.json.tmp package.json

  info "Initializing Biome..."
  pnpm exec biome init

  info "Formatting project..."
  pnpm run format

  success "Next.js project setup complete!"

  info "🎉 Next steps:"
  info "  1. cd $project_name"
  info "  2. pnpm dev     - Start development server"
  info "  3. pnpm test    - Run tests"
  info "  4. pnpm lint    - Check code quality"
}

# Setup Vite UI project
setup_node_ui_vite() {
  local project_dir=$1
  local project_name=$(basename "$project_dir")

  section "Setting up Node.js UI project (Vite): $project_name"

  cd "$project_dir" || exit 1

  info "Creating Vite project..."
  pnpm create vite . --template react-ts

  info "Installing common development dependencies..."
  local common_deps
  common_deps=$(jq -r '.common.devDependencies | to_entries | map("@\(.key)@\(.value)") | join(" ")' "$UI_CONFIG")
  pnpm add -D $common_deps

  info "Installing Vite specific dependencies..."
  local vite_deps
  vite_deps=$(jq -r '.vite.dependencies | to_entries | map("@\(.key)@\(.value)") | join(" ")' "$UI_CONFIG")
  pnpm add $vite_deps

  local vite_dev_deps
  vite_dev_deps=$(jq -r '.vite.devDependencies | to_entries | map("@\(.key)@\(.value)") | join(" ")' "$UI_CONFIG")
  pnpm add -D $vite_dev_deps

  info "Setting up test environment..."
  mkdir -p test
  local files
  files=$(jq -r '.vite.structure.files | to_entries[] | "\(.key) \(.value)"' "$UI_CONFIG")
  while read -r file content; do
    echo "$content" > "$file"
  done <<< "$files"

  info "Updating package.json scripts..."
  local scripts
  scripts=$(jq -r '.common.scripts' "$UI_CONFIG")
  jq --argjson scripts "$scripts" '.scripts *= $scripts' package.json > package.json.tmp
  mv package.json.tmp package.json

  info "Initializing Biome..."
  pnpm exec biome init

  info "Formatting project..."
  pnpm run format

  success "Vite project setup complete!"

  info "🎉 Next steps:"
  info "  1. cd $project_name"
  info "  2. pnpm dev     - Start development server"
  info "  3. pnpm test    - Run tests"
  info "  4. pnpm lint    - Check code quality"
}

# Export functions
export -f setup_node_ui_next
export -f setup_node_ui_vite 
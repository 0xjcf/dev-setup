#!/bin/bash

# Source core modules
source "$BOOTSTRAP_ROOT/core/core.sh"

# Load UI configuration
UI_CONFIG="$BOOTSTRAP_ROOT/config/node/next.json"

setup_node_ui_next() {
    local project_dir="$1"
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
    info "  1. cd $project_dir"
    info "  2. pnpm dev     - Start development server"
    info "  3. pnpm test    - Run tests"
    info "  4. pnpm lint    - Check code quality"
    
    info "📚 Project structure:"
    info "  src/"
    info "    ├── app/        - Next.js app directory"
    info "    ├── components/ - React components"
    info "    └── types/      - TypeScript type definitions"
    info "  "
    info "  test/            - Test files"
}

# Export functions
export -f setup_node_ui_next 
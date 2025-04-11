#!/bin/bash

set -e

echo "🧠 Welcome to the Universal Bootstrapper"

DRY_RUN=false
NON_INTERACTIVE=false
CONFIG_FILE=""
TECH=""
CLASS=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --yes|-y) NON_INTERACTIVE=true ;;
    --tech=*) TECH="${1#*=}" ;;
    --tech) TECH="$2"; shift ;;
    --class=*) CLASS="${1#*=}" ;;
    --class) CLASS="$2"; shift ;;
    --config=*) CONFIG_FILE="${1#*=}" ;;
    --config) CONFIG_FILE="$2"; shift ;;
    --help|-h)
      echo "Usage: ./bootstrap.sh [options]"
      echo ""
      echo "Options:"
      echo "  --dry-run        Print what would happen without executing"
      echo "  --yes, -y        Run without interactive prompts"
      echo "  --tech=TYPE      Technology stack (node, rust, go)"
      echo "  --class=TYPE     Project class (api, ui, lib, cli)"
      echo "  --config=FILE    Load configuration from FILE"
      echo "  --help, -h       Show this help message"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# ─────────────────────────────────────────────────────────────────────────────
# Utilities
# ─────────────────────────────────────────────────────────────────────────────
log() { echo -e "$1"; }

run_or_dry() {
  $DRY_RUN && echo "🚫 (dry-run) $*" || eval "$@"
}

prompt() {
  local message=$1 default=$2
  $NON_INTERACTIVE && echo "$default" || { read -p "$message [$default]: " input; echo "${input:-$default}"; }
}

confirm() {
  $NON_INTERACTIVE && return 0 || { read -p "$1 (y/n): " input; [[ "$input" == "y" ]]; }
}

validate_monorepo_json() {
  local file=$1
  if [ ! -f "$file" ]; then
    echo "❌ Config file not found: $file"
    return 1
  fi

  # Check if file is valid JSON
  if ! jq empty "$file" >/dev/null 2>&1; then
    echo "❌ Invalid JSON in config file: $file"
    return 1
  fi

  # Validate schema
  local valid=$(jq '
    .projects | if type == "array" then
      all(
        .[] |
        has("path") and
        has("type") and
        has("class") and
        .type | inside(["node", "rust", "go"]) and
        .class | inside({
          "node": ["api", "ui", "lib", "cli"],
          "rust": ["agent", "api", "cli", "lib"],
          "go": ["api", "cli", "lib", "agent"]
        }[.type])
      )
    else false end
  ' "$file")

  if [ "$valid" != "true" ]; then
    echo "❌ Invalid schema in config file: $file"
    return 1
  fi

  return 0
}

load_from_config() {
  local file=$1
  if [ -n "$file" ]; then
    if validate_monorepo_json "$file"; then
      echo "📋 Loading configuration from $file"
      jq -c '.projects[]' "$file" | while read -r project; do
        local path=$(echo "$project" | jq -r '.path')
        local tech=$(echo "$project" | jq -r '.type')
        local class=$(echo "$project" | jq -r '.class')
        
        echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 Processing project from config:"
        echo "📁 Path: $path"
        echo "🛠  Tech: $tech"
        echo "📝 Type: $class"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        run_bootstrap_for_dir "$path" "$tech" "$class"
      done
      exit 0
    else
      echo "❌ Failed to load configuration from $file"
      exit 1
    fi
  fi
}

# GLOBAL VAR for capturing selection
SELECTED_OPTION=""

select_option() {
  local prompt_msg="$1"
  shift
  local options=("$@")
  local choice

  echo ""
  for i in "${!options[@]}"; do
    echo "$((i + 1))) ${options[$i]}"
  done
  echo ""

  while true; do
    read -p "$prompt_msg " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
      SELECTED_OPTION="${options[$((choice - 1))]}"
      echo "✅ Selected: $SELECTED_OPTION"
      return
    else
      echo "❌ Invalid option. Please enter a number between 1 and ${#options[@]}."
    fi
  done
}

write_monorepo_json() {
  local path=$1 type=$2 class=$3
  [[ ! -f .monorepo.json ]] && echo '{ "projects": [] }' > .monorepo.json
  if ! grep -q "\"path\": \"$path\"" .monorepo.json; then
    tmp=$(mktemp)
    jq ".projects += [{\"path\": \"$path\", \"type\": \"$type\", \"class\": \"$class\"}]" .monorepo.json > "$tmp" && mv "$tmp" .monorepo.json
    echo "📦 Added '$path' to .monorepo.json as { type: $type, class: $class }"
  fi
}

# Get latest version of a package
get_latest_version() {
  local package=$1
  npm view "$package" version 2>/dev/null || echo "latest"
}

# Update package versions in package.json
update_package_versions() {
  local package_json=$1
  local tmp_file=$(mktemp)
  
  # Get latest versions
  local express_version=$(get_latest_version express)
  local types_express_version=$(get_latest_version @types/express)
  local types_node_version=$(get_latest_version @types/node)
  local typescript_version=$(get_latest_version typescript)
  local tsx_version=$(get_latest_version tsx)
  local vitest_version=$(get_latest_version vitest)
  local biome_version=$(get_latest_version @biomejs/biome)
  local vite_version=$(get_latest_version vite)
  local react_version=$(get_latest_version react)
  local react_dom_version=$(get_latest_version react-dom)
  local types_react_version=$(get_latest_version @types/react)
  local types_react_dom_version=$(get_latest_version @types/react-dom)
  local playwright_version=$(get_latest_version @playwright/test)

  # Update package.json with latest versions while preserving scripts
  jq --arg ev "$express_version" \
     --arg tev "$types_express_version" \
     --arg tnv "$types_node_version" \
     --arg tsv "$typescript_version" \
     --arg txv "$tsx_version" \
     --arg vtv "$vitest_version" \
     --arg bv "$biome_version" \
     '.dependencies.express = "^" + $ev |
      .devDependencies["@types/express"] = "^" + $tev |
      .devDependencies["@types/node"] = "^" + $tnv |
      .devDependencies.typescript = "^" + $tsv |
      .devDependencies.tsx = "^" + $txv |
      .devDependencies.vitest = "^" + $vtv |
      .devDependencies["@biomejs/biome"] = $bv |
      del(.dependencies.react) |
      del(.dependencies["react-dom"]) |
      del(.devDependencies["@types/react"]) |
      del(.devDependencies["@types/react-dom"]) |
      del(.devDependencies.biome) |
      .scripts = {
        "dev": "tsx watch src/index.ts",
        "test": "vitest",
        "lint": "biome check --apply .",
        "build": "tsc",
        "start": "node dist/index.js",
        "check": "tsc --noEmit",
        "audit": "pnpm audit",
        "update-deps": "./scripts/update-deps.sh"
      }' \
     "$package_json" > "$tmp_file" && mv "$tmp_file" "$package_json"
}

generate_justfile() {
  local tech=$1 class=$2
  local justfile_content=""

  case "$tech" in
    node)
      case "$class" in
        api)
          justfile_content="
# Node.js API project tasks
default:
  @just --list

dev:
  pnpm dev

test:
  pnpm test

lint:
  pnpm lint

build:
  pnpm build
"
          ;;
        ui)
          justfile_content="
# Node.js UI project tasks
default:
  @just --list

dev:
  pnpm dev

test:
  pnpm test

lint:
  pnpm lint

build:
  pnpm build

audit:
  pnpm audit
"
          ;;
        lib)
          justfile_content="
# Node.js Library project tasks
default:
  @just --list

test:
  pnpm test

lint:
  pnpm lint

build:
  pnpm build

publish:
  pnpm publish
"
          ;;
        cli)
          justfile_content="
# Node.js CLI project tasks
default:
  @just --list

dev:
  pnpm dev

test:
  pnpm test

lint:
  pnpm lint

build:
  pnpm build

install:
  pnpm install -g .
"
          ;;
      esac
      ;;
    rust)
      case "$class" in
        agent)
          justfile_content="
# Rust Agent project tasks
default:
  @just --list

dev:
  cargo run

test:
  cargo test

lint:
  cargo clippy

build:
  cargo build --release

train:
  cargo run --bin train
"
          ;;
        api)
          justfile_content="
# Rust API project tasks
default:
  @just --list

dev:
  cargo run

test:
  cargo test

lint:
  cargo clippy

build:
  cargo build --release
"
          ;;
        cli)
          justfile_content="
# Rust CLI project tasks
default:
  @just --list

dev:
  cargo run

test:
  cargo test

lint:
  cargo clippy

build:
  cargo build --release

install:
  cargo install --path .
"
          ;;
        lib)
          justfile_content="
# Rust Library project tasks
default:
  @just --list

test:
  cargo test

lint:
  cargo clippy

build:
  cargo build --release

publish:
  cargo publish
"
          ;;
      esac
      ;;
    go)
      case "$class" in
        api)
          justfile_content="
# Go API project tasks
default:
  @just --list

dev:
  go run main.go

test:
  go test ./...

lint:
  golangci-lint run

build:
  go build -o bin/api
"
          ;;
        cli)
          justfile_content="
# Go CLI project tasks
default:
  @just --list

dev:
  go run main.go

test:
  go test ./...

lint:
  golangci-lint run

build:
  go build -o bin/cli

install:
  go install
"
          ;;
        lib)
          justfile_content="
# Go Library project tasks
default:
  @just --list

test:
  go test ./...

lint:
  golangci-lint run

build:
  go build ./...
"
          ;;
      esac
      ;;
  esac

  if [ -n "$justfile_content" ]; then
    echo "$justfile_content" > justfile
    echo "📝 Generated justfile for $tech $class project"
  fi
}

generate_meta_json() {
  local dir=$1 tech=$2 class=$3
  local entry_point=""

  case "$tech" in
    node)
      case "$class" in
        api|ui) entry_point="src/index.ts" ;;
        lib) entry_point="src/index.ts" ;;
        cli) entry_point="src/cli.ts" ;;
      esac
      ;;
    rust)
      case "$class" in
        agent|api|cli) entry_point="src/main.rs" ;;
        lib) entry_point="src/lib.rs" ;;
      esac
      ;;
    go)
      case "$class" in
        api|cli) entry_point="main.go" ;;
        lib) entry_point="lib.go" ;;
      esac
      ;;
  esac

  cat > "$dir/.meta.json" << EOF
{
  "tech": "$tech",
  "class": "$class",
  "entry": "$entry_point"
}
EOF
  echo "📝 Generated .meta.json for $tech $class project"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Process templates from meta.json
process_templates() {
  local dir=$1
  local tech=$2
  local class=$3
  local meta_file="$SCRIPT_DIR/templates/$tech/$class/meta.json"
  
  echo "📁 Processing templates from $meta_file"
  echo "📁 Target directory: $dir"
  
  if [[ ! -f "$meta_file" ]]; then
    echo "❌ Meta file not found: $meta_file"
    return 1
  fi
  
  # Read variables from meta.json
  local project_name=$(basename "$dir")
  local version="1.0.0"
  local port="3000"
  
  echo "📦 Project name: $project_name"
  
  # Process each file in meta.json
  while IFS= read -r file_entry; do
    local path=$(echo "$file_entry" | jq -r '.path')
    local template=$(echo "$file_entry" | jq -r '.template')
    local vars=$(echo "$file_entry" | jq -r '.variables[]?' 2>/dev/null)
    
    local template_path="$SCRIPT_DIR/templates/$tech/$class/$template"
    local output_path="$dir/$path"
    
    echo "📄 Processing template: $template_path"
    echo "📄 Output path: $output_path"
    
    # Build variables string
    local var_string=""
    for var in $vars; do
      case "$var" in
        project_name) var_string+="project_name=$project_name " ;;
        version) var_string+="version=$version " ;;
        port) var_string+="port=$port " ;;
      esac
    done
    
    echo "🔧 Variables: $var_string"
    
    process_template "$template_path" "$output_path" "$var_string"
  done < <(jq -c '.files[]' "$meta_file" 2>/dev/null)
}

# Process a template file with variables
process_template() {
  local template=$1
  local output=$2
  local vars=$3
  
  echo "📄 Processing file: $template -> $output"
  
  if [[ ! -f "$template" ]]; then
    echo "❌ Template file not found: $template"
    return 1
  fi
  
  # Create output directory if it doesn't exist
  mkdir -p "$(dirname "$output")"
  
  # Copy template to output
  cp "$template" "$output"
  echo "✅ Copied template to output"
  
  # Replace basic variables
  for var in $vars; do
    local name="${var%%=*}"
    local value="${var#*=}"
    echo "🔄 Replacing {{$name}} with $value"
    sed -i '' "s/{{$name}}/$value/g" "$output"
  done

  # If this is a package.json template, replace dependency versions
  if [[ "$template" == *"package.json.tpl" ]]; then
    # Get latest versions
    local express_version=$(get_latest_version express)
    local types_express_version=$(get_latest_version @types/express)
    local types_node_version=$(get_latest_version @types/node)
    local typescript_version=$(get_latest_version typescript)
    local tsx_version=$(get_latest_version tsx)
    local vitest_version=$(get_latest_version vitest)
    local biome_version=$(get_latest_version @biomejs/biome)

    # Replace dependency versions
    sed -i '' "s/{{dependencies.express}}/^$express_version/g" "$output"
    sed -i '' "s/{{devDependencies.@types\/express}}/^$types_express_version/g" "$output"
    sed -i '' "s/{{devDependencies.@types\/node}}/^$types_node_version/g" "$output"
    sed -i '' "s/{{devDependencies.typescript}}/^$typescript_version/g" "$output"
    sed -i '' "s/{{devDependencies.tsx}}/^$tsx_version/g" "$output"
    sed -i '' "s/{{devDependencies.vitest}}/^$vitest_version/g" "$output"
    sed -i '' "s/{{devDependencies.biome}}/$biome_version/g" "$output"
  fi
}

scaffold_project() {
  local dir=$1
  local tech=$2
  local class=$3
  local project_name=$(basename "$dir")
  
  echo "🚀 Scaffolding project:"
  echo "📁 Directory: $dir"
  echo "🛠  Tech: $tech"
  echo "📝 Class: $class"
  
  # Create project directories
  mkdir -p "$dir"
  
  # Process templates
  process_templates "$dir" "$tech" "$class"
  
  # Install dependencies if Node.js project
  if [[ "$tech" == "node" ]]; then
    # Save original package.json content
    local package_json="$dir/package.json"
    local package_json_backup=$(mktemp)
    cp "$package_json" "$package_json_backup"
    
    # Install dependencies
    (cd "$dir" && pnpm install)
    
    # Initialize biome configuration
    if [[ "$class" != "lib" ]]; then
      (cd "$dir" && pnpm exec biome init)
      
      # Restore our original package.json content
      cp "$package_json_backup" "$package_json"
      rm "$package_json_backup"
      
      # Reinstall to ensure everything is in sync
      (cd "$dir" && pnpm install)
    fi
  fi
  
  echo "✅ Finished scaffolding $tech $class project"
}

# ─────────────────────────────────────────────────────────────────────────────
# Bootstrap Logic
# ─────────────────────────────────────────────────────────────────────────────
generate_monorepo_justfile() {
  local dir=$1
  cat > "$dir/justfile" << EOF
# Monorepo Tasks
set dotenv-load := true

# Bootstrap all projects
bootstrap:
  ./bootstrap.sh

# Run health check
healthcheck:
  ./healthcheck.sh

# Development
dev:
  # Start all services in development mode
  just dev-api &
  just dev-ui &
  wait

# Testing
test:
  # Run all tests
  just test-api
  just test-ui
  just test-lib
  just test-cli

# Quality Assurance
lint:
  just lint-api
  just lint-ui
  just lint-lib
  just lint-cli

check:
  just check-api
  just check-ui
  just check-lib
  just check-cli

audit:
  just audit-api
  just audit-ui
  just audit-lib
  just audit-cli

# Cleanup
clean:
  # Clean all build artifacts
  just clean-api
  just clean-ui
  just clean-lib
  just clean-cli

# API Service
dev-api:
  cd api && just dev

test-api:
  cd api && just test

lint-api:
  cd api && just lint

check-api:
  cd api && just check

audit-api:
  cd api && just audit

clean-api:
  cd api && just clean

# UI Service
dev-ui:
  cd ui && just dev

test-ui:
  cd ui && just test

lint-ui:
  cd ui && just lint

check-ui:
  cd ui && just check

audit-ui:
  cd ui && just audit

clean-ui:
  cd ui && just clean

# Library
dev-lib:
  cd lib && just dev

test-lib:
  cd lib && just test

lint-lib:
  cd lib && just lint

check-lib:
  cd lib && just check

audit-lib:
  cd lib && just audit

clean-lib:
  cd lib && just clean

# CLI
dev-cli:
  cd cli && just dev

test-cli:
  cd cli && just test

lint-cli:
  cd cli && just lint

check-cli:
  cd cli && just check

audit-cli:
  cd cli && just audit

clean-cli:
  cd cli && just clean

# Docker
docker-build:
  docker build -t app .

docker-run:
  docker run -p 3000:3000 app
EOF
  echo "📝 Generated monorepo justfile"
}

generate_cursor_tools() {
  local dir=$1
  mkdir -p "$dir/.cursor"
  cat > "$dir/.cursor/tools.mdc" << EOF
# Project Tool Manifest

This file provides context for AI agents working in the project.

## Project Structure
- \`api/\`: Backend service
- \`ui/\`: Frontend application
- \`lib/\`: Shared libraries
- \`cli/\`: Command-line tools

## Available Commands
- \`just dev\`: Start all services
- \`just test\`: Run all tests
- \`just build\`: Build all projects
- \`just clean\`: Clean build artifacts
- \`just lint\`: Run linters
- \`just check\`: Type checking
- \`just audit\`: Check dependencies

## Environment
- Node.js v20+
- Rust stable
- pnpm for Node.js
- direnv for environment variables

## Toolchain
- \`biome\` for formatting/linting
- \`vitest\` for testing
- \`playwright\` for E2E tests
- \`workbox-cli\` for PWA generation
- \`@lhci/cli\` for Lighthouse audits

## Best Practices
1. Follow Conventional Commits
2. Write tests for new features
3. Document public APIs
4. Keep dependencies updated
5. Use type checking
EOF
  echo "📝 Generated .cursor/tools.mdc"
}

run_bootstrap_for_dir() {
  local dir="$1"
  local tech="$2"
  local class="$3"
  
  # If this is the root directory, generate monorepo files
  if [ "$(basename "$dir")" = "MVP_Kit" ]; then
    run_or_dry generate_monorepo_justfile "$dir"
    run_or_dry generate_cursor_tools "$dir"
  fi

  log "\n📁 Processing directory: $dir"

  if [ ! -d "$dir" ]; then
    if confirm "❓ Create directory '$dir'?"; then
      run_or_dry mkdir -p "$dir"
    else
      log "⏭ Skipping $dir"
      return
    fi
  fi

  $DRY_RUN && echo "🚫 (dry-run) cd $dir" || cd "$dir"

  local PROJECT_NAME
  PROJECT_NAME=$(basename "$dir")
  log "🔧 Bootstrapping project: $PROJECT_NAME"

  # Only prompt for tech/class if not provided
  if [ -z "$tech" ]; then
    echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🧪 Step 1: Select Technology Stack"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    select_tech_stack
    tech="$SELECTED_OPTION"
  fi

  if [ -z "$class" ]; then
    echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🧠 Step 2: Select Project Type"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    select_project_class "$tech"
    class="$SELECTED_OPTION"
  fi

  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚙️  Project Configuration"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 Project: $PROJECT_NAME"
  echo "🛠  Tech: $tech"
  echo "📝 Type: $class"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  [ -f .envrc ] && log "⚙️ Trusting direnv..." && run_or_dry direnv allow

  # Generate project-specific files
  run_or_dry generate_justfile "$tech" "$class"
  run_or_dry generate_meta_json "$dir" "$tech" "$class"
  run_or_dry scaffold_project "$dir" "$tech" "$class"

  # Node setup
  if [[ "$tech" == "node" ]]; then
    run_or_dry VOLTA_FEATURE_PNPM=1 volta install node@20 pnpm@8.6.3
    run_or_dry volta pin node@20 pnpm@8.6.3

    [ -f pnpm-lock.yaml ] && log "📦 Installing dependencies..." && run_or_dry pnpm install

    log "🧪 Installing dev toolchain..."
    case "$class" in
      api)
        run_or_dry pnpm add -D vitest
        ;;
      ui)
        run_or_dry pnpm add -D vitest @playwright/test workbox-cli @lhci/cli npm-check-updates
        ;;
    esac
  fi

  # Rust setup
  if [[ "$tech" == "rust" && -f Cargo.toml ]]; then
    log "🦀 Rust detected. Setting up toolchain..."
    run_or_dry rustup component add clippy rustfmt || true
    run_or_dry cargo check
  fi

  # Go setup
  if [[ "$tech" == "go" ]]; then
    if ! $DRY_RUN && ! command -v go &>/dev/null; then
      log "❌ Go is not installed. Please run ./setup.sh or install via 'brew install go'"
      return
    fi

    if [ -f go.mod ]; then
      log "🐹 Go project detected. Running go mod tidy..."
      run_or_dry go mod tidy
    else
      log "⚠️ No go.mod found. Skipping go mod tidy."
    fi
  fi

  log "✅ Finished bootstrapping: $PROJECT_NAME"

  $DRY_RUN || write_monorepo_json "$dir" "$tech" "$class"
  $DRY_RUN || cd - > /dev/null
}

# ─────────────────────────────────────────────────────────────────────────────
# Entry Point
# ─────────────────────────────────────────────────────────────────────────────
load_from_config "$CONFIG_FILE"

if confirm "📦 Is this a monorepo setup?"; then
  while true; do
    dir=$(prompt "📂 Enter folder to bootstrap (leave blank to finish)" "")
    [[ -z "$dir" ]] && break
    run_bootstrap_for_dir "$dir"
  done
else
  run_bootstrap_for_dir "$(pwd)"
fi

# Function to select tech stack
select_tech_stack() {
  if [[ -n "$TECH" ]]; then
    SELECTED_OPTION="$TECH"
    echo "✅ Using tech stack: $TECH"
    return
  fi
  
  local options=("node" "rust" "go")
  if $NON_INTERACTIVE; then
    SELECTED_OPTION="node"
    echo "✅ Using default tech stack: node"
    return
  fi
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧪 Step 1: Select Technology Stack"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  select_option "Select tech stack:" "${options[@]}"
}

# Function to select project class
select_project_class() {
  local tech=$1
  if [[ -n "$CLASS" ]]; then
    SELECTED_OPTION="$CLASS"
    echo "✅ Using project class: $CLASS"
    return
  fi
  
  local options
  case "$tech" in
    node) options=("api" "ui" "lib" "cli") ;;
    rust) options=("agent" "api" "lib" "cli") ;;
    go) options=("api" "lib" "cli") ;;
  esac
  
  if $NON_INTERACTIVE; then
    SELECTED_OPTION="${options[0]}"
    echo "✅ Using default project class: ${options[0]}"
    return
  fi
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧠 Step 2: Select Project Type"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  select_option "Select ${tech^} project type:" "${options[@]}"
}

# Main function
main() {
  echo "🧠 Welcome to the Universal Bootstrapper"
  
  # Handle configuration file
  if [[ -n "$CONFIG_FILE" ]]; then
    process_config_file "$CONFIG_FILE"
  else
    # Process current directory
    local dir="$(pwd)"
    local project_name=$(basename "$dir")
    
    # Select tech stack
    select_tech_stack
    local tech="$SELECTED_OPTION"
    echo "🛠  Selected tech stack: $tech"
    
    # Select project class
    select_project_class "$tech"
    local class="$SELECTED_OPTION"
    echo "📝 Selected project class: $class"
    
    # Run bootstrap
    run_bootstrap_for_dir "$dir" "$tech" "$class"
  fi
}

# Run main function
main

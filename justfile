# 🚀 Dev Setup Project Tasks

# Default task: List available tasks
default:
    @echo "Available commands:"
    @just --list

# Root directory for bootstrapped test projects, relative to workspace root
BOOTSTRAP_TEST_ROOT := "../bootstrap-test"

# --- Configuration Variables ---

# --- Core Bootstrap & Setup ---

# Run the main bootstrap script (interactive unless --yes)
bootstrap *ARGS:
    #!/usr/bin/env bash
    echo "🔧 Running main bootstrap script..."
    # Ensure execution permissions
    chmod +x ./bootstrap.sh
    ./bootstrap.sh {{ARGS}}

# Run the setup script (assumes bootstrap completed)
setup:
    #!/usr/bin/env bash
    echo "⚙️ Running environment setup script..."
    chmod +x ./setup.sh
    ./setup.sh

# Run health checks
healthcheck:
    #!/usr/bin/env bash
    echo "🩺 Running health checks..."
    chmod +x ./healthcheck.sh
    ./healthcheck.sh

# --- Bootstrap Specific Project Types (into {{BOOTSTRAP_TEST_ROOT}}/) ---
# These tasks clean the target dir and run bootstrap.sh
# NOTE: Output dir is relative to the WORKSPACE root (../)

# Define top-level variables for dynamic path construction
# PROJECT_TYPE := "{{TECH}}-{{CLASS}}{{ if FRAMEWORK != '' { '-' + FRAMEWORK } else { '' } }}"
# Output relative to the workspace root, not dev-setup root
# TARGET_DIR := "{{BOOTSTRAP_TEST_ROOT}}/{{TECH}}/test-{{CLASS}}{{ if FRAMEWORK != '' { '-' + FRAMEWORK } else { '' } }}"

_bootstrap_project TECH CLASS FRAMEWORK="":
    #!/usr/bin/env bash
    set -e
    # Define shell variables inside the recipe for correct parameter interpolation
    _PROJECT_TYPE="{{TECH}}-{{CLASS}}{{ if FRAMEWORK != '' { '-' + FRAMEWORK } else { '' } }}"
    # Target directory relative to the WORKSPACE root (../), not the dev-setup directory
    _TARGET_DIR="{{BOOTSTRAP_TEST_ROOT}}/{{TECH}}/test-{{CLASS}}{{ if FRAMEWORK != '' { '-' + FRAMEWORK } else { '' } }}"

    echo "⚡ Bootstrapping ${_PROJECT_TYPE} project into ${_TARGET_DIR}..."
    echo "Cleaning ${_TARGET_DIR}..."
    rm -rf "${_TARGET_DIR}"
    # Let bootstrap.sh handle directory creation via --target-dir
    # mkdir -p "${_TARGET_DIR}"

    echo "Running bootstrap script (./bootstrap.sh) with target dir..."
    # # Store current dir # No longer needed
    # _ORIGINAL_DIR=$(pwd)
    # # Change into target dir # Removed - Pass target dir as arg instead
    # cd "${_TARGET_DIR}"

    # Run bootstrap script from current dir (dev-setup)
    # Pass --yes for non-interactive mode and the target directory
    ./bootstrap.sh --yes --tech "{{TECH}}" --class "{{CLASS}}" {{ if FRAMEWORK != '' { '--framework ' + FRAMEWORK } else { '' } }} --target-dir "${_TARGET_DIR}"

    # # Go back to original directory # No longer needed
    # cd "${_ORIGINAL_DIR}"

    # Check exit code of bootstrap script explicitly if needed
    if [[ $? -ne 0 ]]; then
        echo "❌ ERROR: Bootstrap script failed."
        exit 1
    fi

    echo "✅ ${_PROJECT_TYPE} bootstrap complete in ${_TARGET_DIR}."

bootstrap-node-api:
    @just _bootstrap_project node api

bootstrap-node-ui-next:
    @just _bootstrap_project node ui next

bootstrap-node-ui-vite:
    @just _bootstrap_project node ui vite

bootstrap-rust-cli:
    @just _bootstrap_project rust cli

bootstrap-rust-api:
    @just _bootstrap_project rust api

bootstrap-rust-agent:
    @just _bootstrap_project rust agent

# --- Test Bootstrapped Projects (in {{BOOTSTRAP_TEST_ROOT}}/) ---
# These tasks CD into the bootstrapped project dir and run tests.
# NOTE: Paths are relative to the WORKSPACE root (../)

# Shared testing logic for Node.js projects
_test_node_project PROJECT_PATH:
    #!/usr/bin/env bash
    set -e # Exit immediately if a command exits with a non-zero status.

    echo "Changing directory to {{PROJECT_PATH}}"
    cd "{{PROJECT_PATH}}"

    echo "🧪 Testing Node.js project in $(pwd)..."
    echo "📦 Installing dependencies with pnpm..."
    # Use silent reporter unless debug mode is enabled (check if $DEBUG_MODE is set)
    pnpm_install_flags=""
    if [[ -z "$DEBUG_MODE" || "$DEBUG_MODE" == "false" ]]; then
      pnpm_install_flags="--reporter=silent"
    fi
    pnpm install $pnpm_install_flags

    echo "🧹 Formatting with biome (checking)..."
    # Assuming pnpm format script runs 'biome format .'
    # Running format without --write acts as a check
    # Use pnpm exec to ensure project's biome version is used
    pnpm exec biome format .

    echo "🔬 Linting with biome..."
    # Assuming pnpm lint script runs 'biome check .'
    pnpm lint

    # echo "🩺 Running type checks..." # Often redundant if tests include checks
    # pnpm typecheck

    echo "⚙️ Running tests with vitest..."
    # Assuming pnpm test script runs 'vitest run'
    pnpm test

    echo "✅ Node.js project test complete: {{PROJECT_PATH}}"
    # No need for 'cd -', the script block exits and returns to original dir

# Test specific Node.js project types
# Uses the shared Node.js test logic
test-node-api:
    @just _test_node_project "{{BOOTSTRAP_TEST_ROOT}}/node/test-api"
test-node-cli:
    @just _test_node_project "{{BOOTSTRAP_TEST_ROOT}}/node/test-cli"
test-node-lib:
    @just _test_node_project "{{BOOTSTRAP_TEST_ROOT}}/node/test-lib"
test-node-pwa:
    @just _test_node_project "{{BOOTSTRAP_TEST_ROOT}}/node/test-pwa-sveltekit"
test-node-svektekit:
    @just _test_node_project "{{BOOTSTRAP_TEST_ROOT}}/node/test-web-sveltekit"
test-node-react:
    @just _test_node_project "{{BOOTSTRAP_TEST_ROOT}}/node/test-web-react"

# Shared testing logic for Rust projects
_test_rust_project PROJECT_PATH:
    cd "{{PROJECT_PATH}}"
    echo "🧪 Testing Rust project in $(pwd)..."
    echo "🧹 Formatting with rustfmt..."
    cargo fmt --all -- --check
    echo "🔬 Linting with clippy..."
    cargo clippy --all-targets -- -D warnings
    echo "⚙️ Running tests with cargo nextest..."
    cargo nextest run
    echo "✅ Rust project test complete: {{PROJECT_PATH}}"
    cd -

# Test specific Rust project types
# Uses the shared Rust test logic
test-rust-cli:
    @just _test_rust_project "{{BOOTSTRAP_TEST_ROOT}}/rust/test-cli"
test-rust-lib:
    @just _test_rust_project "{{BOOTSTRAP_TEST_ROOT}}/rust/test-lib"

# Specific test logic for Rust API projects (includes docker)
_test_rust_api_project PROJECT_PATH:
    cd "{{PROJECT_PATH}}"
    echo "🧪 Testing Rust API project in $(pwd)..."
    echo "🧹 Formatting with rustfmt..."
    cargo fmt --all -- --check
    echo "🔬 Linting with clippy..."
    cargo clippy --all-targets -- -D warnings
    echo "⚙️ Running tests with cargo nextest..."
    cargo nextest run
    echo "🐳 Building Docker image..."
    # Use shell command for basename
    _BASENAME=$(basename "{{PROJECT_PATH}}")
    docker build -t "rust-api-test-${_BASENAME}" .
    echo "✅ Rust API project test complete: {{PROJECT_PATH}}"
    cd -

test-rust-api:
    @just _test_rust_api_project "{{BOOTSTRAP_TEST_ROOT}}/rust/test-api"

# Run all bootstrap tests
test-all-bootstrap: test-node-api test-node-cli test-node-lib test-node-pwa test-node-svektekit test-node-react test-rust-cli test-rust-lib test-rust-api

# --- Docker Tasks for Bootstrapped Projects (in {{BOOTSTRAP_TEST_ROOT}}/) ---
# NOTE: Paths are relative to the WORKSPACE root (../)

# Generic Docker build task
_docker_build PROJECT_PATH IMAGE_TAG:
    #!/usr/bin/env bash
    set -e
    _PROJECT_DIR="{{PROJECT_PATH}}" # Store the path passed from just
    _IMAGE_TAG="{{IMAGE_TAG}}"     # Store the tag passed from just

    echo "Attempting to change directory to: ${_PROJECT_DIR}"
    if ! cd "${_PROJECT_DIR}"; then
        echo "❌ Error: Failed to change directory to ${_PROJECT_DIR}. Current dir: $(pwd)"
        exit 1
    fi
    
    echo "🐳 Building Docker image ${_IMAGE_TAG} in $(pwd)..." # Use the stored tag

    # Check if Dockerfile exists in docker subdirectory relative to current dir
    if [ -f "docker/Dockerfile" ]; then
        echo "Found Dockerfile in docker/ subdirectory."
        docker build -t "${_IMAGE_TAG}" -f docker/Dockerfile .
    # Fallback to check for Dockerfile in current dir (project root)
    elif [ -f "Dockerfile" ]; then
        echo "Found Dockerfile in project root."
        docker build -t "${_IMAGE_TAG}" .
    else
        echo "❌ Error: Dockerfile not found in $(pwd) or $(pwd)/docker"
        exit 1
    fi
    
    echo "✅ Docker build complete for ${_IMAGE_TAG}"

# Generic Docker Compose task
_docker_compose PROJECT_PATH SERVICE_NAME:
    #!/usr/bin/env bash
    set -e
    _PROJECT_DIR="{{PROJECT_PATH}}"
    _SERVICE_NAME="{{SERVICE_NAME}}"

    echo "Attempting to change directory to: ${_PROJECT_DIR}"
    if ! cd "${_PROJECT_DIR}"; then
        echo "❌ Error: Failed to change directory to ${_PROJECT_DIR}. Current dir: $(pwd)"
        exit 1
    fi

    echo "🐳 Running Docker Compose service ${_SERVICE_NAME} in $(pwd)..."

    # Check if docker-compose.yml exists in docker subdirectory
    if [ -f "docker/docker-compose.yml" ]; then
        echo "Found docker-compose.yml in docker/ subdirectory. Running from there."
        # Docker Compose typically expects to be run where the file is
        cd docker || exit 1 
        docker compose up -d "${_SERVICE_NAME}"
    # Fallback to check for docker-compose.yml in project root
    elif [ -f "docker-compose.yml" ]; then
         echo "Found docker-compose.yml in project root. Running from here."
         docker compose up -d "${_SERVICE_NAME}"
    else
        echo "❌ Error: docker-compose.yml not found in $(pwd) or $(pwd)/docker"
        exit 1
    fi
    
    echo "✅ Docker Compose service ${_SERVICE_NAME} started."

# Docker build tasks for specific projects
docker-node-api-build:
    @just _docker_build "{{BOOTSTRAP_TEST_ROOT}}/node/test-api" "test-node-api"
docker-node-pwa-build:
    @just _docker_build "{{BOOTSTRAP_TEST_ROOT}}/node/test-pwa-sveltekit" "test-node-pwa"
docker-rust-api-build:
    @just _docker_build "{{BOOTSTRAP_TEST_ROOT}}/rust/test-api" "test-rust-api"

# Docker compose tasks for specific projects (if applicable)
# Example:
docker-node-api-up:
    @just _docker_compose "{{BOOTSTRAP_TEST_ROOT}}/node/test-api" "api"

# --- Template Development & Validation ---

# Create a new template structure (interactive)
template-new:
    #!/usr/bin/env bash
    echo "Creating new template structure..."
    ./scripts/template_manager.sh new

# Validate all templates
template-validate:
    #!/usr/bin/env bash
    echo "Validating all templates..."
    ./scripts/template_manager.sh validate_all

# Process a specific template (for testing generation)
# Usage: just template-process <template_path> <output_dir> [vars...]
template-process TEMPLATE_PATH OUTPUT_DIR *VARS:
    #!/usr/bin/env bash
    echo "Processing template '{{TEMPLATE_PATH}}' into '{{OUTPUT_DIR}}'..."
    # Use the process_template.sh script (assuming it exists)
    # Ensure the script has execute permissions
    chmod +x ./scripts/process_template.sh
    ./scripts/process_template.sh "{{TEMPLATE_PATH}}" "{{OUTPUT_DIR}}" {{VARS}}

# Generate the workflow diagram from docs
diagram:
    #!/usr/bin/env bash
    echo "📊 Generating workflow diagram from docs/workflow.md..."
    WORKFLOW_DOC="./docs/workflow.md"
    DIAGRAM_OUT="./docs/workflow-diagram.png"
    if [ ! -f "$WORKFLOW_DOC" ]; then echo "❌ Workflow doc not found: $WORKFLOW_DOC"; exit 1; fi
    # Extract mermaid diagram
    sed -n '/```mermaid/,/```/p' "$WORKFLOW_DOC" | sed '1d;$d' > temp-diagram.mmd
    # Check if mmdc is installed
    if ! command -v mmdc &> /dev/null; then
        echo "❌ mmdc (mermaid-cli) not found. Please install: npm install -g @mermaid-js/mermaid-cli"
        rm temp-diagram.mmd
        exit 1
    fi
    # Generate diagram
    mmdc -i temp-diagram.mmd -o "$DIAGRAM_OUT"
    rm temp-diagram.mmd
    echo "✅ Diagram generated: $DIAGRAM_OUT"

# View project documentation (requires glow)
docs:
    #!/usr/bin/env bash
    echo "📚 Viewing project documentation (requires glow)..."
    if ! command -v glow &> /dev/null; then
        echo "❌ glow not found. Please install glow."
        exit 1
    fi
    # List key docs or open main README
    glow README.md
    echo "\nOther docs in ./docs/ folder."

# --- Code Quality & Analysis (within dev-setup project) ---

# Run linters (shellcheck for scripts)
lint:
    #!/usr/bin/env bash
    echo "🔍 Linting shell scripts with shellcheck..."
    if ! command -v shellcheck &> /dev/null; then
        echo "❌ shellcheck not found. Please install shellcheck."
        exit 1
    fi
    find . -name '*.sh' -print0 | xargs -0 shellcheck

# Format shell scripts (requires shfmt)
format:
    #!/usr/bin/env bash
    echo "💅 Formatting shell scripts with shfmt..."
    if ! command -v shfmt &> /dev/null; then
        echo "❌ shfmt not found. Please install shfmt (e.g., brew install shfmt)."
        exit 1
    fi
    find . -name '*.sh' -print0 | xargs -0 shfmt -w -i 4

# Run tests specific to dev-setup (if any - e.g., testing utility scripts)
test:
    #!/usr/bin/env bash
    echo "🧪 Running tests for dev-setup scripts (if any)..."
    # Add calls to test scripts here if they exist
    # Example: ./tests/run_all_tests.sh
    echo "(No dev-setup specific tests defined yet)"

# Analyze code size and structure
analyze:
    #!/usr/bin/env bash
    echo "📊 Analyzing dev-setup codebase..."
    tokei .
    echo "\n📁 Directory Structure:"
    eza --tree --level=2

# --- Dependency Management (within dev-setup, if applicable) ---
# Example: check-deps for shell utilities
check-deps:
    #!/usr/bin/env bash
    echo "📦 Checking dev-setup dependencies (shellcheck, shfmt, mmdc, etc.)..."
    command -v shellcheck >/dev/null 2>&1 || { echo >&2 "❌ shellcheck not installed."; exit 1; }
    command -v shfmt >/dev/null 2>&1 || { echo >&2 "❌ shfmt not installed."; exit 1; }
    command -v mmdc >/dev/null 2>&1 || { echo >&2 "❌ mmdc (mermaid-cli) not installed."; exit 1; }
    command -v glow >/dev/null 2>&1 || { echo >&2 "❌ glow not installed."; exit 1; }
    command -v eza >/dev/null 2>&1 || { echo >&2 "❌ eza not installed."; exit 1; }
    command -v tokei >/dev/null 2>&1 || { echo >&2 "❌ tokei not installed."; exit 1; }
    command -v direnv >/dev/null 2>&1 || { echo >&2 "❌ direnv not installed."; exit 1; }
    echo "✅ All checked dependencies are installed."

# update-deps could involve brew update/upgrade or similar

# --- Cleanup ---
clean:
    echo "🧹 Cleaning generated test projects..."
    rm -rf "{{BOOTSTRAP_TEST_ROOT}}"
    echo "✅ Clean up complete." 
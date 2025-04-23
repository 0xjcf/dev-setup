# 🚀 Dev Setup Project Tasks

# Default task: List available tasks
default:
    @echo "Available commands:"
    @just --list

# Root directory for bootstrapped test projects, relative to workspace root
BOOTSTRAP_ROOT := "../Kayla-Northington"

# --- Configuration Variables ---

# --- Core Bootstrap & Setup ---

# Run the main bootstrap script (interactive unless --yes)
bootstrap *ARGS:
    #!/usr/bin/env bash
    echo "🔧 Running main bootstrap script..."
    # Ensure execution permissions
    chmod +x ./scripts/bootstrap.sh
    ./scripts/bootstrap.sh {{ARGS}}

# Run the setup script (assumes bootstrap completed)
setup:
    #!/usr/bin/env bash
    echo "⚙️ Running environment setup script..."
    chmod +x ./scripts/setup.sh
    ./scripts/setup.sh

# Run health checks
healthcheck:
    #!/usr/bin/env bash
    echo "🩺 Running health checks..."
    chmod +x ./scripts/healthcheck.sh
    ./scripts/healthcheck.sh

# --- Project Specific Setup ---

# Setup the prompts directory structure for the Kayla-Northington project
setup-prompts:
    #!/usr/bin/env bash
    echo "🏗️ Setting up prompts directory structure..."
    chmod +x ./scripts/setup_prompts_structure.sh
    # Create default phases and placeholder files in the target project
    ./scripts/setup_prompts_structure.sh --create-placeholders "{{BOOTSTRAP_ROOT}}"

# --- Bootstrap Specific Project Types (into {{BOOTSTRAP_ROOT}}/) ---
# These tasks clean the target dir and run bootstrap.sh
# NOTE: Output dir is relative to the WORKSPACE root (../)

# Define top-level variables for dynamic path construction
# PROJECT_TYPE := "{{TECH}}-{{CLASS}}{{ if FRAMEWORK != '' { '-' + FRAMEWORK } else { '' } }}"
# Output relative to the workspace root, not dev-setup root
# TARGET_DIR := "{{BOOTSTRAP_ROOT}}/{{TECH}}/test-{{CLASS}}{{ if FRAMEWORK != '' { '-' + FRAMEWORK } else { '' } }}"

_bootstrap_project TECH CLASS FRAMEWORK="":
    #!/usr/bin/env bash
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
    ./scripts/bootstrap.sh --yes --tech "{{TECH}}" --class "{{CLASS}}" {{ if FRAMEWORK != '' { '--framework ' + FRAMEWORK } else { '' } }} --target-dir "${_TARGET_DIR}"

    # # Go back to original directory # No longer needed
    # cd "${_ORIGINAL_DIR}"

    # Check exit code of bootstrap script explicitly if needed
    if [[ $? -ne 0 ]]; then
        echo "❌ ERROR: Bootstrap script failed."
        exit 1
    fi

bootstrap-node-api:
    @./scripts/bootstrap.sh --yes --clean --tech node --class api --target-dir "{{BOOTSTRAP_ROOT}}"

bootstrap-node-ui-next:
    @./scripts/bootstrap.sh --yes --clean --tech node --class ui --framework next --target-dir "{{BOOTSTRAP_ROOT}}"

bootstrap-node-ui-vite:
    @./scripts/bootstrap.sh --yes --clean --tech node --class ui --framework vite --target-dir "{{BOOTSTRAP_ROOT}}"

bootstrap-rust-cli:
    @./scripts/bootstrap.sh --yes --clean --tech rust --class cli --target-dir "{{BOOTSTRAP_ROOT}}"

bootstrap-rust-api:
    @./scripts/bootstrap.sh --yes --clean --tech rust --class api --target-dir "{{BOOTSTRAP_ROOT}}"

bootstrap-rust-agent:
    @./scripts/bootstrap.sh --yes --clean --tech rust --class agent --target-dir "{{BOOTSTRAP_ROOT}}"

# --- Test Bootstrapped Projects (in {{BOOTSTRAP_ROOT}}/) ---
# These tasks now run bootstrap.sh with --run-tests, which includes cleaning.

# Test specific Node.js project types
i-test-node-api:
    @./scripts/bootstrap.sh --yes --clean --run-tests --tech node --class api --target-dir "{{BOOTSTRAP_ROOT}}"

# Add recipes for the current UI scaffolds
i-test-node-ui-next:
    @./scripts/bootstrap.sh --yes --clean --run-tests --tech node --class ui --framework next --target-dir "{{BOOTSTRAP_ROOT}}"
i-test-node-ui-vite:
    @./scripts/bootstrap.sh --yes --clean --run-tests --tech node --class ui --framework vite --target-dir "{{BOOTSTRAP_ROOT}}"

# Test specific Rust project types
i-test-rust-cli:
    @./scripts/bootstrap.sh --yes --clean --run-tests --tech rust --class cli --target-dir "{{BOOTSTRAP_ROOT}}"

# Add recipe for rust-agent
i-test-rust-agent:
    @./scripts/bootstrap.sh --yes --clean --run-tests --tech rust --class agent --target-dir "{{BOOTSTRAP_ROOT}}"

i-test-rust-api:
    @./scripts/bootstrap.sh --yes --clean --run-tests --tech rust --class api --target-dir "{{BOOTSTRAP_ROOT}}"

# Run all bootstrap tests
# This runs the actual test suites *within* each bootstrapped project
test-all: i-test-node-api i-test-node-ui-next i-test-node-ui-vite i-test-rust-cli i-test-rust-agent i-test-rust-api

# Run the comprehensive scaffold test script
test-scaffolds:
    #!/usr/bin/env bash
    echo "🧪 Running comprehensive scaffold test script..."
    chmod +x ./scripts/test-all-scaffolds.sh
    ./scripts/test-all-scaffolds.sh

# --- Template Development & Validation ---

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
    @echo "🧹 Cleaning generated test projects..."
    @rm -rf "{{BOOTSTRAP_ROOT}}"
    @echo "✅ Clean up complete." 
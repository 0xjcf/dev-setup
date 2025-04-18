#!/bin/bash

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions (now includes new log functions)
source "$SCRIPT_DIR/../bootstrap/utils/common.sh"

# Source function scripts
source "$SCRIPT_DIR/../bootstrap/functions/selection.sh"
source "$SCRIPT_DIR/../bootstrap/functions/config.sh"
source "$SCRIPT_DIR/../bootstrap/functions/scaffolding.sh"

# Source tech-specific setup scripts
source "$SCRIPT_DIR/../bootstrap/tech-setup/node.sh"
source "$SCRIPT_DIR/../bootstrap/tech-setup/rust.sh" # Add later
# source "$SCRIPT_DIR/bootstrap/tech-setup/go.sh"   # Add later

# ------------------------------------------------------
# Global Variables & Argument Parsing
# ------------------------------------------------------

DRY_RUN=false
NON_INTERACTIVE=false
CLEAN_TARGET=false
RUN_TESTS=false
DEBUG_MODE=false # Default to false
CONFIG_FILE=""
TARGET_DIR="" # New variable for target directory
TECH="" # Can be pre-set by flags
CLASS="" # Can be pre-set by flags
FRAMEWORK="" # Can be pre-set by flags (or selected later)
SELECTED_OPTION="" # Used by select_option

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;; # DRY_RUN already handled by run_or_dry
    --yes|-y) NON_INTERACTIVE=true ;; # TODO: Ensure selection functions respect this
    --clean) CLEAN_TARGET=true ;; # New flag to clean target dir
    --run-tests) RUN_TESTS=true ;; # New flag to run tests after bootstrap
    --debug) DEBUG_MODE=true ;; # Enable debug logging
    --target-dir=*) TARGET_DIR="${1#*=}" ;; # Capture target dir
    --target-dir) TARGET_DIR="$2"; shift ;;  # Capture target dir
    --tech=*) TECH="${1#*=}" ;;
    --tech) TECH="$2"; shift ;;
    --class=*) CLASS="${1#*=}" ;;
    --class) CLASS="$2"; shift ;;
    --framework=*) FRAMEWORK="${1#*=}" ;;
    --framework) FRAMEWORK="$2"; shift ;;
    --config=*) CONFIG_FILE="${1#*=}" ;;
    --config) CONFIG_FILE="$2"; shift ;;
    --help|-h)
      echo "Usage: ./bootstrap.sh [options]"
      echo ""
      echo "Options:"
      echo "  --clean          Remove target directory before bootstrapping"
      echo "  --run-tests      Run project tests after successful bootstrapping"
      echo "  --dry-run        Print what would happen without executing"
      echo "  --yes, -y        Run without interactive prompts (uses defaults)"
      echo "  --debug          Enable detailed debug logging"
      echo "  --target-dir=DIR Target directory for scaffolding (required if not using --config)"
      echo "  --tech=TYPE      Pre-set technology stack (node, rust, go)"
      echo "  --class=TYPE     Pre-set project class (api, ui, lib, cli, agent)"
      echo "  --framework=TYPE Pre-set UI framework (if tech=node, class=ui)"
      echo "  --config=FILE    Load configuration from FILE (monorepo setup)"
      echo "  --help, -h       Show this help message"
      exit 0
      ;;
    *) log_error "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# Export DEBUG_MODE so sourced scripts can see it
export DEBUG_MODE

# ------------------------------------------------------
# Helper Function Definitions (Now in separate files)
# ------------------------------------------------------

# Main scaffolding orchestrator
scaffold_project() {
  local dir=$1 tech=$2 class=$3 framework=$4
  log_header "Scaffolding Project"
  log_info "Directory: $dir"

  # Ensure target directory exists, but don't error if it does (CLI tools might create it)
  run_or_dry mkdir -p "$dir"
  
  # --- Phase 1: Base Scaffolding (CLI tools for UI, templates otherwise) ---
  if [[ "$tech" == "node" && "$class" == "ui" && -n "$framework" ]]; then
    log_info "UI project with framework detected. Running base scaffolder first..."
    # Call the base scaffolder for UI projects
    skaffold_node_ui_base "$dir" "$framework" # Pass only dir and framework
    local base_status=$?
    if [[ $base_status -ne 0 ]]; then
       log_error "Failed during initial Node.js UI base scaffolding for framework $framework."
       return 1
    fi
  fi
  
  # --- Phase 2: Apply Custom Templates ---
  # This runs for ALL project types, overlaying our specific files
  process_templates "$dir" "$tech" "$class" "$framework"
  local process_status=$?
  if [[ $process_status -ne 0 ]]; then
    log_error "Failed during template processing."
    return 1
  fi

  # --- Phase 3: Final Setup (Install deps, Biome, etc.) ---
  log_info "Running final setup phase for $tech project..."
  if [[ "$tech" == "node" ]]; then
    finalize_node_setup "$dir" "$class" "$framework" # Call the new finalizer
  elif [[ "$tech" == "rust" ]]; then
    finalize_rust_setup "$dir" "$class" # Call the Rust finalizer
    # log_warning "Rust final setup not yet implemented."
  elif [[ "$tech" == "go" ]]; then
    # setup_go_project "$dir" "$class"   # Placeholder for Go final setup
    log_warning "Go final setup not yet implemented."
  # No final 'else' needed here; if tech isn't matched, we just finish.
  fi
  local final_status=$?
  if [[ $final_status -ne 0 ]]; then
     log_error "Failed during final setup phase for $tech."
     return 1
  fi
  # --- End Final Setup ---

  return 0
}

# ------------------------------------------------------
# Testing Logic
# ------------------------------------------------------

run_project_tests() {
  local dir=$1 tech=$2 class=$3 # Framework might be needed later
  local project_name=$(basename "$dir")

  log_header "Running Tests for: $project_name"

  # Need to change into the directory to run tests
  local original_dir=$(pwd)
  cd "$dir" || { log_error "Failed to cd into $dir to run tests"; return 1; }
  trap 'cd "$original_dir"' RETURN # Ensure we cd back even on errors

  local test_status=0

  case "$tech" in
    node)
      log_info "🧹 Formatting check (biome)..."
      if ! run_or_dry pnpm exec biome format .; then test_status=1; fi
      log_info "🔬 Linting check (biome)..."
      if ! run_or_dry pnpm lint; then test_status=1; fi
      log_info "⚙️ Running unit tests (pnpm test)..."
      # Run pnpm test directly to see output, then check status
      pnpm test
      local pnpm_test_status=$?
      if [[ $pnpm_test_status -ne 0 ]]; then
          log_error "pnpm test command failed with status $pnpm_test_status"
          test_status=1 # Mark overall test status as failed
      fi
      ;;
    rust)
      log_info "🧹 Formatting check (cargo fmt)..."
      if ! run_or_dry cargo fmt --all -- --check; then test_status=1; fi
      log_info "🔬 Linting check (cargo clippy)..."
      if ! run_or_dry cargo clippy --all-targets -- -D warnings; then test_status=1; fi
      log_info "⚙️ Running unit tests (cargo nextest)..."
      if ! run_or_dry cargo nextest run; then test_status=1; fi
      ;;
    go)
      log_warning "Go testing execution not implemented yet."
      # Add go test commands here
      ;;
    *)
      log_warning "No testing procedure defined for tech: $tech"
      ;;
  esac

  # cd back explicitly before final message
  cd "$original_dir"
  trap - RETURN # Clear the trap

  if [[ $test_status -eq 0 ]]; then
    log_success "All tests passed for $project_name"
  else
    log_error "Some tests failed for $project_name"
  fi

  return $test_status
}

# ------------------------------------------------------
# Core Bootstrap Logic per Directory
# ------------------------------------------------------

run_bootstrap_for_dir() {
  local dir="$1" # This is now the TARGET_DIR passed from main
  local initial_tech="$2"  # Tech passed in (e.g., from config or flag)
  local initial_class="$3" # Class passed in
  local initial_framework="$4" # Framework passed in

  # --- Clean target directory if requested --- #
  if [[ "$CLEAN_TARGET" == true ]]; then
    if [[ -d "$dir" ]]; then
      log_info "--clean flag specified. Removing existing target directory: $dir"
      if ! run_or_dry rm -rf "$dir"; then
        log_error "Failed to remove target directory: $dir"
        return 1
      fi
    else
      log_debug "--clean flag specified, but target directory does not exist: $dir"
    fi
  fi

  # --- Ensure target directory exists --- #
  log_info "Ensuring target directory exists: $dir"
  if ! mkdir -p "$dir"; then
      log_error "Failed to create target directory: $dir"
      return 1
  fi

  local current_tech="$initial_tech"
  local current_class="$initial_class"
  local current_framework="$initial_framework"

  # Store original directory (which is dev-setup)
  local original_dir="$(pwd)"
  # -- We no longer cd into the target dir here --
  # cd "$dir" || { log_error "Failed to cd into $dir"; return 1; }
  # trap 'cd "$original_dir"' RETURN # No longer needed here

  local project_name
  project_name=$(basename "$dir")
  log_header "Bootstrapping Project: $project_name"
  log_info "Target Directory: $dir"

  # --- Phase 1: Monorepo Check (Handled by main based on --config) ---
  log_debug "Phase 1: Monorepo Check (Skipped for single dir run)"

  # --- Phase 2: Tech Stack Selection ---
  log_header "Selecting Technology Stack"
  if [[ -z "$current_tech" ]]; then
    log_info "No tech pre-set, prompting user..."
    select_tech_stack # Uses functions/selection.sh -> utils/common.sh
    current_tech="$SELECTED_OPTION"
    log_info "User selected tech: $current_tech"
  else
    log_info "Using pre-set tech: $current_tech"
    # TODO: Validate pre-set tech?
  fi

  # --- Phase 3: Project Class Selection ---
  log_header "Selecting Project Class"
  if [[ -z "$current_class" ]]; then
    log_info "No class pre-set, prompting user..."
    select_project_class "$current_tech" # Uses functions/selection.sh
    current_class="$SELECTED_OPTION"
    log_info "User selected class: $current_class"
  else
    log_info "Using pre-set class: $current_class"
    # TODO: Validate pre-set class based on tech?
  fi

  # --- Phase 4: Framework Selection (Conditional) ---
  if [[ "$current_tech" == "node" && "$current_class" == "ui" ]]; then
    log_header "Selecting UI Framework"
    if [[ -z "$current_framework" ]]; then
       log_warning "UI Framework selection not yet implemented (Phase 2+)."
       # TODO: Implement framework selection based on node/ui/metadata.json
       # select_ui_framework # Uses functions/selection.sh
       # current_framework="$SELECTED_OPTION" # Need to capture framework *key*
    else
       log_info "Using pre-set framework: $current_framework"
       # TODO: Validate pre-set framework?
    fi
  else
    log_debug "Skipping UI Framework selection (Tech is $current_tech, Class is $current_class)"
  fi

  log_header "Final Configuration Summary"
  log_info "Project: $project_name"
  log_info "Tech: $current_tech"
  log_info "Class: $current_class"
  log_info "Framework: ${current_framework:-N/A}"

  # --- Phase 5: Project Setup --- # scaffold_project uses headers
  log_header "Starting Project Setup"

  log_info "Generating common configuration files..."
  # Pass the target directory ($dir) as the first argument
  generate_justfile "$dir" "$current_tech" "$current_class" # From scaffolding.sh
  generate_meta_json "$dir" "$current_tech" "$current_class" # From scaffolding.sh

  scaffold_project "$dir" "$current_tech" "$current_class" "$current_framework"
  local scaffold_status=$?
  # Check status after main scaffolding
  if [[ $scaffold_status -ne 0 ]]; then
     log_error "Project setup failed for $project_name."
     # Trap will still cd back
     return 1
  else
     # If --run-tests was passed, run tests now
     if [[ "$RUN_TESTS" == true ]]; then
       run_project_tests "$dir" "$current_tech" "$current_class"
       # Store test status? For now, just let it run.
       # If tests fail, run_project_tests returns non-zero, stopping the script due to 'set -e'
     fi
  fi
}

# ------------------------------------------------------
# Main Entry Point
# ------------------------------------------------------

main() {
  log_debug "Entered main function"
  log_info "🚀 Welcome to the Universal Bootstrapper 🚀"

  # Handle configuration file (monorepo case)
  if [[ -n "$CONFIG_FILE" ]]; then
    log_debug "Config file provided ($CONFIG_FILE), calling load_from_config"
    load_from_config "$CONFIG_FILE" # Uses functions/config.sh
    # load_from_config calls run_bootstrap_for_dir for each project in the file
  else
    # Process target directory (single project case)
    if [[ -z "$TARGET_DIR" ]]; then
      log_error "Missing required argument: --target-dir DIR is required when not using --config"
      exit 1
    fi
    # Ensure target dir is absolute or resolve it
    if [[ "$TARGET_DIR" != /* ]]; then
       TARGET_DIR="$(pwd)/$TARGET_DIR"
       log_debug "Resolved relative target directory to: $TARGET_DIR"
    fi

    log_debug "Processing single project target directory: $TARGET_DIR"
    log_debug "Calling run_bootstrap_for_dir with potentially pre-set flags"
    # Pass TARGET_DIR and flags
    run_bootstrap_for_dir "$TARGET_DIR" "$TECH" "$CLASS" "$FRAMEWORK"
  fi

  log_success "🚀 Universal Bootstrapper finished successfully!"
  log_debug "Exiting main function"
}

# Run main function
main


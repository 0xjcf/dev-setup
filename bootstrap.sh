#!/bin/bash

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions (now includes new log functions)
source "$SCRIPT_DIR/bootstrap/utils/common.sh"

# Source function scripts
source "$SCRIPT_DIR/bootstrap/functions/selection.sh"
source "$SCRIPT_DIR/bootstrap/functions/config.sh"
source "$SCRIPT_DIR/bootstrap/functions/scaffolding.sh"

# Source tech-specific setup scripts
source "$SCRIPT_DIR/bootstrap/tech-setup/node.sh"
# source "$SCRIPT_DIR/bootstrap/tech-setup/rust.sh" # Add later
# source "$SCRIPT_DIR/bootstrap/tech-setup/go.sh"   # Add later

# ------------------------------------------------------
# Global Variables & Argument Parsing
# ------------------------------------------------------

DRY_RUN=false
NON_INTERACTIVE=false
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
  log_info "Tech: $tech"
  log_info "Class: $class"
  log_info "Framework: ${framework:-N/A}"

  # Use run_or_dry for safety
  run_or_dry mkdir -p "$dir"

  process_templates "$dir" "$tech" "$class" # "$framework"
  local process_status=$?
  if [[ $process_status -ne 0 ]]; then
    log_error "Failed during template processing."
    return 1
  fi

  # --- Call Tech-Specific Setup --- # Should use log_header internally
  if [[ "$tech" == "node" ]]; then
    setup_node_project "$dir" "$class" # Call function from tech-setup/node.sh
  elif [[ "$tech" == "rust" ]]; then
    # setup_rust_project "$dir" "$class" # Call later
    log_warning "Rust setup not yet implemented."
  elif [[ "$tech" == "go" ]]; then
    # setup_go_project "$dir" "$class"   # Call later
    log_warning "Go setup not yet implemented."
  else
     log_error "Unknown tech '$tech'. Skipping tech-specific setup."
     return 1 # Treat unknown tech as an error
  fi
  local setup_status=$?
  if [[ $setup_status -ne 0 ]]; then
     log_error "Failed during tech-specific setup for $tech."
     return 1
  fi
  # --- End Tech-Specific Setup ---

  log_info "Finished scaffolding steps."
  return 0
}

# ------------------------------------------------------
# Core Bootstrap Logic per Directory
# ------------------------------------------------------

run_bootstrap_for_dir() {
  local dir="$1" # This is now the TARGET_DIR passed from main
  local initial_tech="$2"  # Tech passed in (e.g., from config or flag)
  local initial_class="$3" # Class passed in
  local initial_framework="$4" # Framework passed in

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
     log_success "Finished bootstrapping: $project_name"
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

  log_debug "Exiting main function"
}

# Run main function
main


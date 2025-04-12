#!/bin/bash

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions
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
CONFIG_FILE=""
TECH="" # Can be pre-set by flags
CLASS="" # Can be pre-set by flags
FRAMEWORK="" # Can be pre-set by flags (or selected later)
SELECTED_OPTION="" # Used by select_option

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --yes|-y) NON_INTERACTIVE=true ;; # Set non-interactive mode
    --tech=*) TECH="${1#*=}" ;;      # Allow pre-setting tech
    --tech) TECH="$2"; shift ;;       # Allow pre-setting tech
    --class=*) CLASS="${1#*=}" ;;     # Allow pre-setting class
    --class) CLASS="$2"; shift ;;      # Allow pre-setting class
    --framework=*) FRAMEWORK="${1#*=}" ;; # Allow pre-setting framework
    --framework) FRAMEWORK="$2"; shift ;; # Allow pre-setting framework
    --config=*) CONFIG_FILE="${1#*=}" ;; # Specify config file
    --config) CONFIG_FILE="$2"; shift ;;  # Specify config file
    --help|-h)
      echo "Usage: ./bootstrap.sh [options]"
      echo ""
      echo "Options:"
      echo "  --dry-run        Print what would happen without executing"
      echo "  --yes, -y        Run without interactive prompts (uses defaults)"
      echo "  --tech=TYPE      Pre-set technology stack (node, rust, go)"
      echo "  --class=TYPE     Pre-set project class (api, ui, lib, cli, agent)"
      echo "  --framework=TYPE Pre-set UI framework (if tech=node, class=ui)"
      echo "  --config=FILE    Load configuration from FILE (monorepo setup)"
      echo "  --help, -h       Show this help message"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# ------------------------------------------------------
# Helper Function Definitions (Moved to functions/)
# ------------------------------------------------------

# TODO: Restore definitions for:
# - update_package_versions (if needed, maybe belongs in tech-setup/node.sh?)
# - generate_monorepo_justfile
# - generate_cursor_tools
# ... and any others called by the above

# Main scaffolding orchestrator
scaffold_project() {
  local dir=$1 tech=$2 class=$3 framework=$4
  log "🚀 Scaffolding project..."
  log "   Directory: $dir"
  log "   Tech: $tech"
  log "   Class: $class"
  log "   Framework: ${framework:-N/A}"
  
  mkdir -p "$dir"
  
  process_templates "$dir" "$tech" "$class" # "$framework" 
  local process_status=$?
  if [[ $process_status -ne 0 ]]; then
    log "❌ Failed during template processing."
    return 1 
  fi

  # --- Call Tech-Specific Setup --- 
  if [[ "$tech" == "node" ]]; then
    setup_node_project "$dir" "$class" # Call function from tech-setup/node.sh
  elif [[ "$tech" == "rust" ]]; then
    # setup_rust_project "$dir" "$class" # Call later
    log "   -> Rust setup (TODO)"
  elif [[ "$tech" == "go" ]]; then
    # setup_go_project "$dir" "$class"   # Call later
    log "   -> Go setup (TODO)"
  else
     log "   ⚠️ Unknown tech '$tech'. Skipping tech-specific setup."
  fi
  local setup_status=$?
  if [[ $setup_status -ne 0 ]]; then
     log "❌ Failed during tech-specific setup for $tech."
     return 1
  fi
  # --- End Tech-Specific Setup ---

  log "   -> Finished scaffolding steps."
  return 0
}

# process_templates() is now defined in scaffolding.sh
# update_package_versions() might need to be restored/reintegrated

# ------------------------------------------------------
# Core Bootstrap Logic per Directory
# ------------------------------------------------------

run_bootstrap_for_dir() {
  local dir="$1"
  local initial_tech="$2"  # Tech passed in (e.g., from config or flag)
  local initial_class="$3" # Class passed in
  local initial_framework="$4" # Framework passed in

  local current_tech="$initial_tech"
  local current_class="$initial_class"
  local current_framework="$initial_framework"

  # Store original directory and ensure we return
  local original_dir="$(pwd)"
  cd "$dir" || { log "❌ Failed to cd into $dir"; return 1; }
  trap 'cd "$original_dir"' RETURN # Ensure we cd back on function exit

  local project_name
  project_name=$(basename "$dir")
  log "\n🔧 Bootstrapping project: $project_name in $dir"

  # --- Phase 1: Monorepo Check (Handled by main based on --config) ---

  # --- Phase 2: Tech Stack Selection ---
  if [[ -z "$current_tech" ]]; then
    select_tech_stack # Uses functions/selection.sh -> utils/common.sh
    current_tech="$SELECTED_OPTION"
  else
    log "✅ Using pre-set tech: $current_tech"
    # TODO: Validate pre-set tech?
  fi

  # --- Phase 3: Project Class Selection ---
  if [[ -z "$current_class" ]]; then
    select_project_class "$current_tech" # Uses functions/selection.sh
    current_class="$SELECTED_OPTION"
  else
    log "✅ Using pre-set class: $current_class"
    # TODO: Validate pre-set class based on tech?
  fi

  # --- Phase 4: Framework Selection (Conditional) ---
  if [[ "$current_tech" == "node" && "$current_class" == "ui" ]]; then
    if [[ -z "$current_framework" ]]; then
       # TODO: Implement framework selection based on node/ui/meta.json
       # select_ui_framework # Uses functions/selection.sh
       # current_framework="$SELECTED_OPTION" # Need to capture framework *key*
       log "🟡 UI Framework selection needed (Phase 2+)"
    else
       log "✅ Using pre-set framework: $current_framework"
       # TODO: Validate pre-set framework?
    fi
  fi

  log "\n⚙️ Final Configuration:"
  log "   Project: $project_name"
  log "   Tech: $current_tech"
  log "   Class: $current_class"
  log "   Framework: ${current_framework:-N/A}"

  # --- Phase 5: Project Setup ---
  log "\n🛠️ Starting Project Setup Phase..."
  
  generate_justfile "$current_tech" "$current_class" # From scaffolding.sh
  generate_meta_json "$dir" "$current_tech" "$current_class" # From scaffolding.sh
  
  scaffold_project "$dir" "$current_tech" "$current_class" "$current_framework"
  local scaffold_status=$?
  # Check status after main scaffolding
  if [[ $scaffold_status -ne 0 ]]; then
     log "❌ Project setup failed for $project_name."
     # No need to return here, trap will cd back
  else
     log "\n✅ Finished bootstrapping: $project_name"
  fi

  # write_monorepo_json ?
}

# ------------------------------------------------------
# Main Entry Point
# ------------------------------------------------------

main() {
  log "DEBUG: Entered main function"
  log "🧠 Welcome to the Universal Bootstrapper"

  # Handle configuration file (monorepo case)
  if [[ -n "$CONFIG_FILE" ]]; then
    log "DEBUG: Config file provided ($CONFIG_FILE), calling load_from_config"
    load_from_config "$CONFIG_FILE" # Uses functions/config.sh
    # load_from_config calls run_bootstrap_for_dir for each project in the file
  else
    # Process current directory (single project case)
    local dir="$(pwd)"
    log "DEBUG: No config file, processing current directory ($dir)"
    log "DEBUG: Calling run_bootstrap_for_dir with potentially pre-set flags"
    # Pass flags ($TECH, $CLASS, $FRAMEWORK) which might be empty or pre-set
    run_bootstrap_for_dir "$dir" "$TECH" "$CLASS" "$FRAMEWORK"
  fi

  log "DEBUG: Exiting main function"
}

# Run main function
main


#!/bin/bash

# Node.js specific setup functions

# Assumes utils like 'log' and 'run_or_dry' are available from the main script
# Assumes necessary variables like $DRY_RUN are set globally

# --- Phase 1: Create Base Project using CLI tools (for UI+Framework) ---
skaffold_node_ui_base() {
  local dir=$1
  local framework=$2
  
  log_header "Node.js UI Base Scaffolding"
  log_info "Directory: $dir"
  log_info "Framework: $framework"
  
  # Store current directory
  local current_dir=$(pwd)
  
  # Change to parent directory of target directory (so we can create the target dir)
  local parent_dir=$(dirname "$dir")
  local project_dir=$(basename "$dir")
  cd "$parent_dir" || { 
    log_error "Failed to cd into parent directory: $parent_dir"
    return 1
  }
  
  # Check if directory already exists - clear it if it does
  if [[ -d "$project_dir" ]]; then
    log_info "Directory $project_dir already exists. Clearing contents..."
    run_or_dry rm -rf "$project_dir"
  fi
  
  case "$framework" in
    next)
      log_info "Creating Next.js project using create-next-app..."
      # --ts = TypeScript, --eslint = no ESLint, --src-dir = use src/ directory
      # --app = use App Router, --import-alias = use @ for import alias
      # --tailwind = use Tailwind, --no-git = don't initialize git repo
      # --turbo = Use Turbopack for dev server
      # Note: create-next-app might still prompt interactively for some options
      if ! run_or_dry pnpm create next-app "$project_dir" --ts --no-eslint --tailwind --src-dir --app --import-alias="@/*" --no-git --use-pnpm --turbo; then
        log_error "Failed to create Next.js project with create-next-app."
        cd "$current_dir"
        return 1
      fi
      # Remove default ESLint config if create-next-app added it despite flag
      log_info "Attempting to remove ESLint config files..."
      if [ -f "$project_dir/.eslintrc.json" ]; then
        log_info "   Found .eslintrc.json, removing..."
        run_or_dry rm -f "$project_dir/.eslintrc.json"
      fi
      if [ -f "$project_dir/eslint.config.mjs" ]; then
        log_info "   Found eslint.config.mjs, removing..."
        run_or_dry rm -f "$project_dir/eslint.config.mjs" # Also remove the newer config file name
      fi
      ;;
    vite)
      log_info "Creating Vite project using create vite..."
      # Create Vite React + TypeScript project
      if ! run_or_dry pnpm create vite "$project_dir" --template react-ts; then
        log_error "Failed to create Vite project with create-vite."
        cd "$current_dir"
        return 1
      fi
      ;;
    *)
      log_error "Unknown UI framework: $framework"
      cd "$current_dir"
      return 1
      ;;
  esac
  
  log_success "Base project scaffold created with official CLI tools for framework '$framework'."
  
  # Return to original directory
  cd "$current_dir"
  return 0
}

# --- Phase 2: Finalize Node Setup (Install deps, Biome, etc.) ---
finalize_node_setup() {
  local dir=$1
  local class=$2
  # Framework might be needed for class-specific finalization later
  # local framework=$3 
  
  log_header "Finalizing Node.js Setup"
  log_info "Directory: $dir"
  
  local package_json="$dir/package.json"
  if [ ! -f "$package_json" ]; then
      log_error "package.json not found in $dir. Cannot finalize Node.js setup."
      return 1 # Indicate failure
  fi

  log_info "Pre-approving build scripts for pnpm via .pnpm.builds.yaml..."
  # Create .pnpm.builds.yaml to allow known scripts non-interactively
  # This should be respected by pnpm install
  # Ensure Biome is allowed if it's a dependency now
  cat << EOF > "$dir/.pnpm.builds.yaml"
allow:
  - esbuild
  - '@biomejs/biome'
  - sharp # Common offender in Next.js projects
EOF
  log_debug "Created/Updated $dir/.pnpm.builds.yaml"

  log_info "Installing final dependencies with pnpm..."
  # Change to the directory to run pnpm commands
  local current_dir=$(pwd)
  cd "$dir" || return 1

  # Use --reporter=silent to reduce pnpm noise, unless in DEBUG_MODE
  local pnpm_install_flags=""
  if [[ -z "$DEBUG_MODE" || "$DEBUG_MODE" == "false" ]]; then
    pnpm_install_flags="--reporter=silent"
  fi

  if ! run_or_dry pnpm install $pnpm_install_flags; then
     log_error "Failed to install final dependencies with pnpm."
     cd "$current_dir"
     return 1
  fi
  log_success "Final dependencies installed."

  # Install testing dependencies for UI projects
  if [[ "$class" == "ui" ]]; then
    log_info "Installing testing dependencies (vitest, testing-library)..."
    # Also need @vitejs/plugin-react for vitest to work with React
    # Also need @testing-library/user-event for simulating user interactions
    if ! run_or_dry pnpm add -D vitest @vitejs/plugin-react @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom $pnpm_install_flags; then
      log_warning "Failed to install testing dependencies. Tests might not run correctly."
      # Decide if this should be fatal
    else
      log_success "Testing dependencies installed."
      # Add/Update "test" script to use vitest ONLY for UI projects
      log_info "Ensuring 'test' script uses vitest in package.json..."
      local temp_pkg_json="${package_json}.tmp"
      # Use jq to update the scripts.test entry. Create scripts object if needed.
      if run_or_dry jq '( .scripts.test = "vitest run" )' "$package_json" > "$temp_pkg_json" && run_or_dry mv "$temp_pkg_json" "$package_json"; then
          log_success "Successfully updated package.json test script."
      else
          log_warning "Failed to update package.json test script using jq."
          # Clean up temp file if mv failed
          [ -f "$temp_pkg_json" ] && run_or_dry rm "$temp_pkg_json"
      fi
    fi
  fi

  # Initialize Biome if config exists and biome is installed
  if [[ "$class" != "lib" ]]; then
    if [ -f "$dir/biome.json" ]; then
        log_info "Biome configuration found. Ensuring Biome is installed and formatting..."
        
        # Ensure biome is installed as a dev dependency
        log_info " -> Ensuring @biomejs/biome is installed..."
        if ! run_or_dry pnpm add -D @biomejs/biome $pnpm_install_flags; then
            log_error "   -> Failed to install @biomejs/biome. Skipping Biome steps."
        else
            log_success "@biomejs/biome installed/verified."
            # Check if biome command is available via pnpm exec NOW
            if run_or_dry pnpm exec biome --version > /dev/null 2>&1; then
               log_info "Formatting codebase with Biome..."
               if ! run_or_dry pnpm exec biome format . --write; then
                   log_warning "Biome formatting command failed. Continuing anyway."
               else
                   log_success "Codebase formatted."
               fi
               log_info "Linting codebase with Biome..."
               if ! run_or_dry pnpm exec biome check . --write; then # Use --write to apply safe fixes
                   log_warning "Biome check/lint command failed. Continuing anyway."
               else
                   log_success "Codebase linted/checked."
               fi
            else
               log_warning "Biome command still not found via pnpm exec after attempting install."
            fi
        fi
    else
        log_info "No biome.json found. Skipping Biome setup."
    fi
  else
     log_info "Skipping Biome setup for library class."
  fi

  # Return to original directory
  cd "$current_dir"

  log_success "Node.js finalization complete."
  return 0
}

# Keep the old function name temporarily for compatibility, but point it to the new one
setup_node_project() {
  finalize_node_setup "$@"
} 
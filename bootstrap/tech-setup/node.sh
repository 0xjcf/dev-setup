#!/bin/bash

# Node.js specific setup function

# Assumes utils like 'log' and 'run_or_dry' are available from the main script
# Assumes necessary variables like $DRY_RUN are set globally

setup_node_project() {
  local dir=$1
  local class=$2
  # local framework=$3 # May be needed later for UI

  log_header "Node.js Setup"
  log_info "Directory: $dir"

  local package_json="$dir/package.json"
  if [ -f "$package_json" ]; then
    log_info "Pre-approving build scripts for pnpm via .pnpm.builds.yaml..."
    # Create .pnpm.builds.yaml to allow known scripts non-interactively
    # This should be respected by pnpm install
    cat << EOF > "$dir/.pnpm.builds.yaml"
allow:
  - esbuild
  - '@biomejs/biome'
EOF
    log_debug "Created $dir/.pnpm.builds.yaml"

    log_info "Installing dependencies with pnpm..."
    local package_json_backup
    package_json_backup=$(mktemp)
    cp "$package_json" "$package_json_backup"

    # Change to the directory to run pnpm commands
    local current_dir=$(pwd)
    cd "$dir" || return 1

    # Use --reporter=silent to reduce pnpm noise, unless in DEBUG_MODE
    local pnpm_install_flags=""
    if [[ -z "$DEBUG_MODE" || "$DEBUG_MODE" == "false" ]]; then
      pnpm_install_flags="--reporter=silent"
    fi

    if ! run_or_dry pnpm install $pnpm_install_flags; then
       log_error "Failed to install dependencies with pnpm."
       cp "$package_json_backup" "$package_json"
       rm "$package_json_backup"
       cd "$current_dir"
       return 1
    fi
    log_success "Dependencies installed."

    # Initialize biome configuration ONLY if biome.json doesn't exist
    if [[ "$class" != "lib" ]]; then
      if [ ! -f "$dir/biome.json" ]; then
          log_info "Initializing Biome (biome.json not found)..."
          # Redirect stdout and stderr to suppress the verbose init message
          if ! run_or_dry pnpm exec biome init > /dev/null 2>&1; then
              log_warning "Failed to initialize Biome even though biome.json was missing."
              # Don't fail the whole bootstrap for this
          else
              log_success "Biome initialized."
          fi
      else
           log_info "Biome configuration (biome.json) already exists. Skipping initialization."
      fi

      # Restore our original package.json (biome init might add itself)
      # cp "$package_json_backup" "$package_json"
      # rm "$package_json_backup" # We'll remove this at the end of the block

      log_info "Formatting codebase with Biome..."
      if ! run_or_dry pnpm exec biome format . --write; then
          log_warning "Biome formatting command failed. Continuing anyway."
          # Don't fail bootstrap for formatting issues, but warn
      else
          log_success "Codebase formatted."
      fi

    else
       log_info "Skipping Biome initialization and formatting for library class."
       # rm "$package_json_backup" # Clean up backup if biome wasn't run
    fi
    
    # Clean up the package.json backup regardless of Biome execution
    rm "$package_json_backup"

    # Install specific dev toolchain dependencies based on class
    log_info "Checking/installing dev toolchain dependencies..."
    case "$class" in
      api)
        # Assuming vitest added via template, maybe verify?
        log_info "  - (API class - vitest expected from template)"
        ;;
      ui)
        # Common UI dev deps - framework deps handled elsewhere
        log_info "  - (UI class - adding common dev tools)"
        # Use silent reporter
        if ! run_or_dry pnpm add -D vitest @playwright/test workbox-cli @lhci/cli npm-check-updates $pnpm_install_flags; then
            log_error "Failed to install UI dev dependencies."
            cd "$current_dir"
            return 1
        fi
        log_success "UI dev dependencies added."
        ;;
      # Add cases for lib, cli if needed
      *)
        log_info "  - (No specific dev toolchain dependencies for class '$class')"
        ;;
    esac

    # Return to original directory
    cd "$current_dir"

  else
      log_error "package.json not found in $dir. Skipping Node.js setup."
      return 1 # Indicate failure or issue
  fi

  log_success "Node.js setup complete."
  return 0
} 
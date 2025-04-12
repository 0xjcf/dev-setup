#!/bin/bash

# Node.js specific setup function

# Assumes utils like 'log' and 'run_or_dry' are available from the main script
# Assumes necessary variables like $DRY_RUN are set globally

setup_node_project() {
  local dir=$1
  local class=$2
  # local framework=$3 # May be needed later for UI

  log "   -> Running Node.js setup in $dir..."

  local package_json="$dir/package.json"
  if [ -f "$package_json" ]; then
    log "      -> Installing dependencies with pnpm..."
    local package_json_backup
    package_json_backup=$(mktemp)
    cp "$package_json" "$package_json_backup"

    # Change to the directory to run pnpm commands
    local current_dir=$(pwd)
    cd "$dir" || return 1

    if ! run_or_dry pnpm install; then
       log "      ❌ Failed to install dependencies with pnpm."
       cp "$package_json_backup" "$package_json"
       rm "$package_json_backup"
       cd "$current_dir"
       return 1
    fi

    # Initialize biome configuration (if not a library)
    if [[ "$class" != "lib" ]]; then
      log "      -> Initializing Biome..."
      if ! run_or_dry pnpm exec biome init; then
          log "      ⚠️ Failed to initialize Biome (might already exist)."
      fi
      
      # Restore our original package.json (biome init might add itself)
      cp "$package_json_backup" "$package_json"
      rm "$package_json_backup"
      
      # Re-run install to sync lockfile
      log "      -> Running pnpm install again to sync lockfile..."
      if ! run_or_dry pnpm install; then
         log "      ❌ Failed during post-biome pnpm install."
         cd "$current_dir"
         return 1
      fi
    else 
       rm "$package_json_backup" # Clean up backup if biome wasn't run
    fi
    
    # Install specific dev toolchain dependencies based on class
    log "      -> Installing dev toolchain dependencies..."
    case "$class" in
      api)
        # Assuming vitest added via template, maybe verify?
        log "         (API class - vitest expected from template)"
        ;;
      ui)
        # Common UI dev deps - framework deps handled elsewhere
        log "         (UI class - adding common dev tools)"
        run_or_dry pnpm add -D vitest @playwright/test workbox-cli @lhci/cli npm-check-updates
        ;;
      # Add cases for lib, cli if needed
    esac
    
    # Return to original directory
    cd "$current_dir"

  else
      log "   ⚠️ package.json not found in $dir. Skipping Node.js setup."
      return 1 # Indicate failure or issue
  fi

  log "   -> Node.js setup complete."
  return 0
} 
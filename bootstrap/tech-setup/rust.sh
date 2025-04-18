#!/bin/bash

# Rust specific finalization function

# Assumes utils like 'log' and 'run_or_dry' are available from the main script

finalize_rust_setup() {
  local dir=$1
  local class=$2
  
  log_header "Finalizing Rust Setup"
  log_info "Directory: $dir"
  
  local cargo_toml="$dir/Cargo.toml"
  if [ ! -f "$cargo_toml" ]; then
      log_error "Cargo.toml not found in $dir. Cannot finalize Rust setup."
      return 1 # Indicate failure
  fi

  # Change to the directory to run cargo commands
  local current_dir=$(pwd)
  cd "$dir" || return 1

  log_info "Running cargo check..."
  if ! run_or_dry cargo check; then
     log_warning "cargo check failed. Check dependencies and code."
     # Don't necessarily fail the whole bootstrap, but warn
  else
     log_success "cargo check completed successfully."
  fi
  
  # Optional: Add cargo fmt check?
  # log_info "Checking formatting with cargo fmt..."
  # if ! run_or_dry cargo fmt --all -- --check; then
  #    log_warning "Code formatting issues detected. Run 'cargo fmt' to fix."
  # else
  #    log_success "Code formatting is correct."
  # fi

  # Return to original directory
  cd "$current_dir"

  log_success "Rust finalization complete."
  return 0
} 
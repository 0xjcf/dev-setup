#!/bin/bash

# Simple script to test all scaffolds and update SCAFFOLD_PROGRESS.md

set -e # Exit on error

# Record the start time
START_TIME=$(date +%s)

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to log with color
log() {
  echo -e "${BOLD}${2:-$NC}$1${NC}"
}

# Function to log success
log_success() {
  log "✅ $1" $GREEN
}

# Function to log error
log_error() {
  log "❌ $1" $RED
}

# Function to log warning
log_warning() {
  log "⚠️ $1" $YELLOW
}

# Clean the bootstrap-test directory first
log "Cleaning up bootstrap-test directory..."
just clean

# List of scaffolds to test
SCAFFOLDS=(
  "node-api"
  "node-ui-next"
  "node-ui-vite"
  "rust-api"
  "rust-cli"
  "rust-agent"
  # "go-agent" # Uncomment when implemented
)

SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILED_SCAFFOLDS=()

# Test each scaffold
for scaffold in "${SCAFFOLDS[@]}"; do
  log_warning "\n==== Testing scaffold: $scaffold ===="
  
  # Run the bootstrap
  if just bootstrap-$scaffold; then
    # Verify the project was created
    # Let's simplify: construct path based on components
    IFS='-' read -r tech rest <<< "$scaffold"
    PROJECT_DIR="../bootstrap-test/${tech}/test-${rest}"

    log "Verifying project directory: $PROJECT_DIR"
    if [ -d "$PROJECT_DIR" ]; then
      if [ -f "$PROJECT_DIR/package.json" ] || [ -f "$PROJECT_DIR/Cargo.toml" ] || [ -f "$PROJECT_DIR/go.mod" ]; then
        log_success "Scaffold $scaffold created successfully!"
        ((SUCCESS_COUNT++))
      else
        log_error "Scaffold $scaffold created directory but missing main package file"
        ((FAILURE_COUNT++))
        FAILED_SCAFFOLDS+=("$scaffold")
      fi
    else
      log_error "Scaffold $scaffold failed to create project directory"
      ((FAILURE_COUNT++))
      FAILED_SCAFFOLDS+=("$scaffold")
    fi
  else
    log_error "Scaffold $scaffold failed during bootstrap"
    ((FAILURE_COUNT++))
    FAILED_SCAFFOLDS+=("$scaffold")
  fi
done

# Record the end time and calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# Print summary
echo ""
log_warning "==== Scaffold Testing Summary ===="
log "Total scaffolds tested: ${#SCAFFOLDS[@]}"
log_success "Successful: $SUCCESS_COUNT"
if [ $FAILURE_COUNT -gt 0 ]; then
  log_error "Failed: $FAILURE_COUNT"
  log_error "Failed scaffolds: ${FAILED_SCAFFOLDS[*]}"
else
  log_success "All scaffolds completed successfully!"
fi
log "Time taken: ${MINUTES}m ${SECONDS}s"

# Remind user to update SCAFFOLD_PROGRESS.md
echo ""
log_warning "Remember to update prompts/SCAFFOLD_PROGRESS.md with the test results!"
echo "" 
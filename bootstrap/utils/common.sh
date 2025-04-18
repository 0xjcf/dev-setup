#!/bin/bash

# Common utility functions

# Define colors for logging (optional, checks for terminal compatibility)
if [[ -t 1 ]]; then # Check if stdout is a terminal
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
  C_BLUE='\033[34m'
  C_GREEN='\033[32m'
  C_YELLOW='\033[33m'
  C_RED='\033[31m'
  C_MAGENTA='\033[35m'
else
  C_RESET=''
  C_BOLD=''
  C_BLUE=''
  C_GREEN=''
  C_YELLOW=''
  C_RED=''
  C_MAGENTA=''
fi

# --- Logging Functions ---

# General info log (always prints)
log_info() {
  echo -e "${C_BLUE}INFO:${C_RESET} $1"
}

# Success log (always prints)
log_success() {
  echo -e "${C_GREEN}✅ SUCCESS:${C_RESET} $1"
}

# Warning log (always prints)
log_warning() {
  echo -e "${C_YELLOW}⚠️ WARNING:${C_RESET} $1"
}

# Error log (always prints)
log_error() {
  echo -e "${C_RED}❌ ERROR:${C_RESET} $1" >&2 # Errors go to stderr
}

# Debug log (only prints if DEBUG_MODE is set, e.g., DEBUG_MODE=true ./bootstrap.sh)
log_debug() {
  if [[ -n "$DEBUG_MODE" && "$DEBUG_MODE" != "false" ]]; then
    echo -e "${C_MAGENTA}DEBUG:${C_RESET} $1"
  fi
}

# Header log for sections
log_header() {
  echo -e "\n${C_BOLD}${C_BLUE}--- $1 ---${C_RESET}"
}

# Legacy log function (maps to log_info for compatibility, consider phasing out)
log() {
  log_info "$1"
}

# --- Execution Functions ---

# Execute a command or print it during dry run
run_or_dry() {
  local cmd_string
  cmd_string=$(printf ' %q' "$@") # Safely quote arguments
  log_debug "Executing: $cmd_string"
  if [[ $DRY_RUN == true ]]; then
    echo "[DRY RUN] Would execute: $cmd_string"
    return 0 # Assume success for dry run
  else
    # Execute the command, capturing status
    eval "$cmd_string"
    local status=$?
    if [[ $status -ne 0 ]]; then
      log_error "Command failed with status $status: $cmd_string"
    fi
    return $status
  fi
}

# --- Other Utilities ---

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

prompt() {
  local message=$1 default=$2
  $NON_INTERACTIVE && echo "$default" || { read -p "$message [$default]: " input; echo "${input:-$default}"; }
}

confirm() {
  $NON_INTERACTIVE && return 0 || { read -p "$1 (y/n): " input; [[ "$input" == "y" ]]; }
}

select_option() {
  local prompt_msg="$1"
  shift
  local options=("$@")
  local choice

  echo ""
  for i in "${!options[@]}"; do
    echo "$((i + 1))) ${options[$i]}"
  done
  echo ""

  while true; do
    echo "DEBUG: About to prompt user with: $prompt_msg"
    read -p "$prompt_msg " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
      SELECTED_OPTION="${options[$((choice - 1))]}"
      echo "✅ Selected: $SELECTED_OPTION"
      return
    else
      echo "❌ Invalid option. Please enter a number between 1 and ${#options[@]}."
    fi
  done
}

# Get latest version of a package
get_latest_version() {
  local package=$1
  npm view "$package" version 2>/dev/null || echo "latest"
} 
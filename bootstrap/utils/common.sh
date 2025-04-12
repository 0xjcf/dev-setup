#!/bin/bash

# Common utility functions
log() { echo -e "$1"; }

run_or_dry() {
  $DRY_RUN && echo "🚫 (dry-run) $*" || eval "$@"
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
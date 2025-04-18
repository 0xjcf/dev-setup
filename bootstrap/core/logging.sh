#!/bin/bash

# Default log level
export LOG_LEVEL=${LOG_LEVEL:-"INFO"}

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Log level values
DEBUG_LEVEL=0
INFO_LEVEL=1
WARN_LEVEL=2
ERROR_LEVEL=3

# Get log level value
get_log_level() {
  case "$1" in
    "DEBUG") echo $DEBUG_LEVEL ;;
    "INFO") echo $INFO_LEVEL ;;
    "WARN") echo $WARN_LEVEL ;;
    "ERROR") echo $ERROR_LEVEL ;;
    *) echo $INFO_LEVEL ;;
  esac
}

# Main logging function
log() {
  local level=$1
  local message=$2
  local color=$3
  
  if [[ $(get_log_level "$level") -ge $(get_log_level "$LOG_LEVEL") ]]; then
    printf "${color}${level}${NC} ${message}\n"
  fi
}

# Convenience logging functions
debug() {
  log "DEBUG" "$1" "$GRAY"
}

info() {
  log "INFO" "$1" "$BLUE"
}

warn() {
  log "WARN" "$1" "$YELLOW"
}

error() {
  log "ERROR" "$1" "$RED"
}

success() {
  printf "${GREEN}✓${NC} $1\n"
}

section() {
  printf "\n${BOLD}$1${NC}\n"
}

# Progress indicators
start_progress() {
  printf "${BLUE}⟳${NC} $1... "
}

end_progress() {
  local status=$1
  if [[ $status -eq 0 ]]; then
    printf "${GREEN}✓${NC}\n"
  else
    printf "${RED}✗${NC}\n"
  fi
}

# Error handling
handle_error() {
  local error_code=$1
  local error_message=$2
  error "$error_message"
  return $error_code
}

# Interactive prompts
prompt() {
  local message=$1
  local default=$2
  local response
  
  printf "${BLUE}?${NC} ${message} ${GRAY}($default)${NC}: "
  read -r response
  echo "${response:-$default}"
}

confirm() {
  local message=$1
  local response
  
  while true; do
    printf "${BLUE}?${NC} ${message} ${GRAY}(y/n)${NC}: "
    read -r response
    case $response in
      [Yy]* ) return 0 ;;
      [Nn]* ) return 1 ;;
      * ) echo "Please answer yes or no." ;;
    esac
  done
} 
#!/bin/bash

# Common utility functions for bootstrap scripts

# ------------------------------------------------------
# File Operations
# ------------------------------------------------------

ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir" || return 1
    fi
    return 0
}

ensure_file() {
    local file="$1"
    local content="$2"
    if [ ! -f "$file" ]; then
        echo "$content" > "$file"
    fi
}

# ------------------------------------------------------
# Environment
# ------------------------------------------------------

load_env() {
    local env_file="$1"
    if [ -f "$env_file" ]; then
        set -a
        source "$env_file"
        set +a
    fi
}

# ------------------------------------------------------
# Command Execution
# ------------------------------------------------------

run_or_dry() {
    local cmd="$1"
    local dry_run="${2:-false}"
    
    if [ "$dry_run" = true ]; then
        echo "DRY RUN: $cmd"
    else
        eval "$cmd"
    fi
}

# ------------------------------------------------------
# Dependency Management
# ------------------------------------------------------

check_dependency() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ Required dependency not found: $cmd"
        return 1
    fi
    return 0
}

# ------------------------------------------------------
# Project Configuration
# ------------------------------------------------------

get_project_config() {
    local config_file="$1"
    local key="$2"
    
    if [ -f "$config_file" ]; then
        jq -r "$key" "$config_file"
    else
        echo ""
    fi
}

# ------------------------------------------------------
# Template Processing
# ------------------------------------------------------

process_template() {
    local template_file="$1"
    local output_file="$2"
    local variables="$3"
    
    if [ ! -f "$template_file" ]; then
        echo "❌ Template file not found: $template_file"
        return 1
    fi
    
    # Create output directory if it doesn't exist
    mkdir -p "$(dirname "$output_file")"
    
    # Handle JSON files specially
    if [[ "$template_file" == *.json.tpl ]]; then
        # Process template with variables first
        local temp_file=$(mktemp)
        envsubst "$variables" < "$template_file" > "$temp_file"
        
        # Format JSON with jq
        jq '.' "$temp_file" > "$output_file"
        rm "$temp_file"
    else
        # Process non-JSON templates normally
        envsubst "$variables" < "$template_file" > "$output_file"
    fi
    
    if [ ! -f "$output_file" ]; then
        echo "❌ Failed to create output file: $output_file"
        return 1
    fi
    
    return 0
}

# ------------------------------------------------------
# Validation
# ------------------------------------------------------

validate_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "❌ File not found: $file"
        return 1
    fi
    return 0
}

validate_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "❌ Directory not found: $dir"
        return 1
    fi
    return 0
}

# ------------------------------------------------------
# Project Type Validation
# ------------------------------------------------------

validate_project_type() {
    local tech="$1"
    local class="$2"
    local framework="$3"
    
    case "$tech:$class:$framework" in
        "node:api:"|"node:ui:next"|"node:ui:vite"|"node:lib:"|"node:cli:"|"rust:api:"|"rust:lib:"|"rust:cli:"|"go:api:"|"go:lib:"|"go:cli:")
            return 0
            ;;
        *)
            echo "❌ Invalid project type: $tech:$class:$framework"
            return 1
            ;;
    esac
}

# ------------------------------------------------------
# Dependency Validation
# ------------------------------------------------------

validate_dependencies() {
    local tech="$1"
    local class="$2"
    
    case "$tech" in
        "node")
            check_dependency "pnpm" || return 1
            check_dependency "node" || return 1
            ;;
        "rust")
            check_dependency "cargo" || return 1
            ;;
        "go")
            check_dependency "go" || return 1
            ;;
    esac
    
    return 0
} 
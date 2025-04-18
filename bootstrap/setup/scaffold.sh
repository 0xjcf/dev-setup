#!/bin/bash

# Scaffolding functions for bootstrap scripts

# ------------------------------------------------------
# Project Structure
# ------------------------------------------------------

setup_project_structure() {
    local project_type="$1"
    local project_dir="$2"
    local current_dir="$(pwd)"
    
    info "Setting up project structure for $project_type"
    info "Project directory: $project_dir"
    info "Current directory: $current_dir"
    
    # Change to project directory
    if ! cd "$project_dir"; then
        error "Failed to change to project directory: $project_dir"
        return 1
    fi
    
    case "$project_type" in
        "node:api")
            setup_node_api_structure || { cd "$current_dir"; return 1; }
            ;;
        "node:ui:next")
            setup_next_structure || { cd "$current_dir"; return 1; }
            ;;
        "node:ui:vite")
            setup_vite_structure || { cd "$current_dir"; return 1; }
            ;;
        "node:lib")
            setup_node_lib_structure || { cd "$current_dir"; return 1; }
            ;;
        "node:cli")
            setup_node_cli_structure || { cd "$current_dir"; return 1; }
            ;;
        "rust:api")
            setup_rust_api_structure || { cd "$current_dir"; return 1; }
            ;;
        "rust:lib")
            setup_rust_lib_structure || { cd "$current_dir"; return 1; }
            ;;
        "rust:cli")
            setup_rust_cli_structure || { cd "$current_dir"; return 1; }
            ;;
        "go:api")
            setup_go_api_structure || { cd "$current_dir"; return 1; }
            ;;
        "go:lib")
            setup_go_lib_structure || { cd "$current_dir"; return 1; }
            ;;
        "go:cli")
            setup_go_cli_structure || { cd "$current_dir"; return 1; }
            ;;
        *)
            error "Unsupported project type: $project_type"
            cd "$current_dir"
            return 1
            ;;
    esac
    
    # Verify the root test directory was created ONLY for specific types
    if [[ "$project_type" == "node:api" ]]; then # Add other types here if they need a root /test dir
        if [ ! -d "test" ]; then
            error "Root 'test' directory was not created for $project_type in $project_dir"
            ls -la  # Debug: show directory contents
            cd "$current_dir"
            return 1
        fi
        info "Root 'test' directory verified for $project_type"
    fi 
    # For other types (like vite, next), the specific structure functions handle test dir creation (e.g., src/tests)
    
    success "Project structure created"
    cd "$current_dir"
    return 0
}

# ------------------------------------------------------
# Node.js Project Structures
# ------------------------------------------------------

setup_node_api_structure() {
    info "Setting up Node.js API structure"
    
    # Create source directories
    for dir in routes controllers services types; do
        ensure_dir "src/$dir" || return 1
    done
    
    # Create test directory
    ensure_dir "test" || return 1
    
    # Create initial files
    ensure_file "src/index.ts" "" || return 1
    ensure_file "test/index.test.ts" "" || return 1
    
    return 0
}

setup_next_structure() {
    info "Setting up Next.js structure"
    
    # Create source directories individually
    ensure_dir "src/app" || return 1
    ensure_dir "src/components" || return 1
    ensure_dir "src/lib" || return 1
    ensure_dir "src/styles" || return 1
    
    # Create test directory (consistent location)
    ensure_dir "tests" || return 1
    
    return 0
}

setup_vite_structure() {
    info "Setting up Vite structure"
    
    # Create source directories individually
    ensure_dir "src/components" || return 1
    ensure_dir "src/assets" || return 1
    ensure_dir "src/lib" || return 1
    
    # Create test directory (Note: Vite default tests are often co-located in src)
    # Create src/tests for test setup files
    ensure_dir "src/tests" || return 1 
    
    return 0
}

setup_node_lib_structure() {
    info "Setting up Node.js library structure"
    
    # Create source directories
    ensure_dir "src/core" || return 1
    
    # Create test directory
    ensure_dir "test" || return 1
    
    return 0
}

setup_node_cli_structure() {
    info "Setting up Node.js CLI structure"
    
    # Create source directories
    ensure_dir "src/commands" || return 1
    
    # Create test directory
    ensure_dir "test" || return 1
    
    return 0
}

# ------------------------------------------------------
# Rust Project Structures
# ------------------------------------------------------

setup_rust_api_structure() {
    info "Setting up Rust API structure"
    
    # Initialize Cargo project
    cargo init --bin || return 1
    
    # Create source directories
    ensure_dir "src/{routes,handlers,models}" || return 1
    
    # Create test directory
    ensure_dir "tests" || return 1
    
    return 0
}

setup_rust_lib_structure() {
    info "Setting up Rust library structure"
    
    # Initialize Cargo project
    cargo init --lib || return 1
    
    # Create source directories
    ensure_dir "src/core" || return 1
    
    # Create test directory
    ensure_dir "tests" || return 1
    
    return 0
}

setup_rust_cli_structure() {
    info "Setting up Rust CLI structure"
    
    # Initialize Cargo project
    cargo init --bin || return 1
    
    # Create source directories
    ensure_dir "src/commands" || return 1
    
    # Create test directory
    ensure_dir "tests" || return 1
    
    return 0
}

# ------------------------------------------------------
# Go Project Structures
# ------------------------------------------------------

setup_go_api_structure() {
    info "Setting up Go API structure"
    
    # Create source directories
    ensure_dir "cmd/api" || return 1
    ensure_dir "internal/{handlers,models,services}" || return 1
    ensure_dir "pkg/{config,utils}" || return 1
    
    # Create test directory
    ensure_dir "test" || return 1
    
    return 0
}

setup_go_lib_structure() {
    info "Setting up Go library structure"
    
    # Create source directories
    ensure_dir "internal/core" || return 1
    ensure_dir "pkg/utils" || return 1
    
    # Create test directory
    ensure_dir "test" || return 1
    
    return 0
}

setup_go_cli_structure() {
    info "Setting up Go CLI structure"
    
    # Create source directories
    ensure_dir "cmd/cli" || return 1
    ensure_dir "internal/commands" || return 1
    
    # Create test directory
    ensure_dir "test" || return 1
    
    return 0
} 
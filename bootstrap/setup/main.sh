#!/bin/bash

# Main setup functions for bootstrap scripts

# ------------------------------------------------------
# Project Initialization
# ------------------------------------------------------

setup_project() {
    local tech="$1"
    local class="$2"
    local framework="$3"
    local project_dir="$4"
    
    section "Setting up $tech:$class project"
    
    # Validate project type
    validate_project_type "$tech" "$class" "$framework" || return 1
    
    # Validate dependencies
    validate_dependencies "$tech" "$class" || return 1
    
    # Create project directory
    ensure_dir "$project_dir" || return 1
    
    # Setup project based on tech stack
    case "$tech" in
        "node")
            setup_node_project "$class" "$framework" "$project_dir" || return 1
            ;;
        "rust")
            setup_rust_project "$class" "$project_dir" || return 1
            ;;
        "go")
            setup_go_project "$class" "$project_dir" || return 1
            ;;
        *)
            error "Unsupported technology: $tech"
            return 1
            ;;
    esac
    
    success "Project setup complete"
    return 0
}

# ------------------------------------------------------
# Node.js Project Setup
# ------------------------------------------------------

setup_node_project() {
    local class="$1"
    local framework="$2"
    local project_dir="$3"
    
    info "Setting up Node.js $class project"
    
    # Change to project directory
    cd "$project_dir" || return 1
    
    case "$class" in
        "api")
            setup_node_api_project || return 1
            ;;
        "ui")
            setup_node_ui_project "$framework" || return 1
            ;;
        "lib")
            setup_node_lib_project || return 1
            ;;
        "cli")
            setup_node_cli_project || return 1
            ;;
        *)
            error "Unsupported Node.js project class: $class"
            return 1
            ;;
    esac
    
    return 0
}

setup_node_api_project() {
    info "Setting up Node.js API project"
    
    # Initialize project
    pnpm init || return 1
    
    # Create directory structure
    ensure_dir "src/{routes,controllers,services,types}" || return 1
    ensure_dir "test" || return 1
    
    # Install dependencies
    pnpm add express @types/express dotenv typescript tsx || return 1
    pnpm add -D @biomejs/biome @types/node supertest @types/supertest || return 1
    
    # Setup configuration files
    setup_node_config_files || return 1
    
    # Setup scripts
    setup_node_scripts || return 1
    
    return 0
}

setup_node_ui_project() {
    local framework="$1"
    
    info "Setting up Node.js UI project with $framework"
    
    case "$framework" in
        "next")
            setup_next_project || return 1
            ;;
        "vite")
            setup_vite_project || return 1
            ;;
        *)
            error "Unsupported UI framework: $framework"
            return 1
            ;;
    esac
    
    return 0
}

# ------------------------------------------------------
# Configuration Setup
# ------------------------------------------------------

setup_node_config_files() {
    info "Setting up Node.js configuration files"
    
    # Setup TypeScript configuration
    ensure_file "tsconfig.json" '{
        "compilerOptions": {
            "target": "ES2020",
            "module": "commonjs",
            "lib": ["ES2020"],
            "strict": true,
            "esModuleInterop": true,
            "skipLibCheck": true,
            "forceConsistentCasingInFileNames": true,
            "outDir": "dist",
            "rootDir": "src"
        },
        "include": ["src/**/*"],
        "exclude": ["node_modules", "dist"]
    }' || return 1
    
    # Setup Biome configuration
    ensure_file "biome.json" '{
        "$schema": "https://biomejs.dev/schemas/1.5.3/schema.json",
        "organizeImports": {
            "enabled": true
        },
        "linter": {
            "enabled": true,
            "rules": {
                "recommended": true
            }
        },
        "formatter": {
            "enabled": true,
            "formatWithErrors": false,
            "indentStyle": "space",
            "indentWidth": 4,
            "lineWidth": 100
        }
    }' || return 1
    
    return 0
}

# ------------------------------------------------------
# Scripts Setup
# ------------------------------------------------------

setup_node_scripts() {
    info "Setting up Node.js scripts (Note: These might be overridden by templates)"
    
    # These commands modify the package.json created by pnpm init,
    # but they are likely overwritten by template processing later.
    # Keeping them minimal or removing if templates handle everything.
    
    # Example minimal setup if needed, otherwise remove:
    # pnpm pkg set scripts.build="tsc" || return 1
    
    return 0
} 
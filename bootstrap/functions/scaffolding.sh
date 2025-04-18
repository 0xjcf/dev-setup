#!/bin/bash

# Scaffolding helper functions

# Ensure utils are sourced first if helpers depend on them (like log)
# Consider adding: source "$(dirname "$0")/../utils/common.sh" if needed standalone

generate_justfile() {
  local tech=$1 class=$2
  # Get target dir from the first argument of run_bootstrap_for_dir, which should be $1
  # This relies on generate_justfile being called within run_bootstrap_for_dir context
  # Or, more robustly, pass the target dir explicitly: generate_justfile TARGET_DIR TECH CLASS
  local target_dir="$1" # Assuming run_bootstrap_for_dir passes its $1
  shift # Remove target_dir from arguments for tech/class processing
  tech=$1
  class=$2

  # Removed justfile_content variable
  local project_name
  project_name=$(basename "$target_dir") # Get project name from target directory

  # Use cat with heredoc to write directly to file
  local justfile_path="$target_dir/justfile"

  # Determine content based on tech and class
  case "$tech" in
    node)
      case "$class" in
        api)
          # Use heredoc to write content
          cat << EOF > "$justfile_path"
# Node.js API project tasks
default:
  @just --list

dev:
  pnpm dev

test:
  pnpm test

lint:
  pnpm lint

build:
  pnpm build

# --- Docker Commands ---
# Build the docker image (using Dockerfile in ./docker/)
build-docker:
  docker build -t $project_name -f docker/Dockerfile .

# Run the application in docker-compose (detached, using compose file in ./docker/)
dev-docker:
  @docker compose -f docker/docker-compose.yml up --build -d api
  @echo "Container started in detached mode. Following logs (Ctrl+C to stop logs)..."
  @docker compose -f docker/docker-compose.yml logs --follow api

# Run tests within the docker container (using compose file in ./docker/)
test-docker:
  @docker compose -f docker/docker-compose.yml run --rm api pnpm test

# Stop docker-compose services (using compose file in ./docker/)
stop-docker:
  @docker compose -f docker/docker-compose.yml down
EOF
          ;;
        ui)
          # Use heredoc for UI as well
          cat << EOF > "$justfile_path"
# Node.js UI project tasks
default:
  @just --list

dev:
  pnpm dev

test:
  pnpm test

lint:
  pnpm lint

build:
  pnpm build

audit:
  pnpm audit
# Add relevant docker commands for UI if needed
EOF
          ;;
        lib)
          # Use heredoc for Lib
          cat << EOF > "$justfile_path"
# Node.js Library project tasks
default:
  @just --list

test:
  pnpm test

lint:
  pnpm lint

build:
  pnpm build

publish:
  pnpm publish
EOF
          ;;
        cli)
          # Use heredoc for CLI
          cat << EOF > "$justfile_path"
# Node.js CLI project tasks
default:
  @just --list

dev:
  pnpm dev

test:
  pnpm test

lint:
  pnpm lint

build:
  pnpm build

install:
  pnpm install -g .
EOF
          ;;
        *)
          log_warning "⚠️ No specific Node.js justfile template found for class $class"
          # Optionally create a minimal default justfile
          cat << EOF > "$justfile_path"
# Default tasks
default:
  @just --list
EOF
          ;;
      esac
      ;; # End node case
    rust)
      # ... Apply heredoc pattern for Rust cases ...
      log_warning "⚠️ Rust justfile generation using heredoc not fully implemented yet."
      # Ensure file is created even if content is basic
      cat << EOF > "$justfile_path"
# Default tasks for Rust project
default:
  @just --list
EOF
      ;; # End rust case
    go)
      # ... Apply heredoc pattern for Go cases ...
      log_warning "⚠️ Go justfile generation using heredoc not fully implemented yet."
      # Ensure file is created even if content is basic
      cat << EOF > "$justfile_path"
# Default tasks for Go project
default:
  @just --list
EOF
      ;; # End go case
    *)
      log_warning "⚠️ No justfile template found for tech $tech"
      # Ensure file is created even if content is basic
      cat << EOF > "$justfile_path"
# Default tasks
default:
  @just --list
EOF
      ;; # End default case
  esac

  # Check if file was created successfully by cat
  if [[ $? -eq 0 && -f "$justfile_path" ]]; then
    log_info "📝 Generated justfile for $tech $class project in $target_dir"
  elif [[ ! -f "$justfile_path" ]]; then # Handle cases where cat might have failed silently or no case matched
    log_error "❌ Failed to generate justfile: $justfile_path (File not found after attempted creation)"
  fi
  # No need to return 1 here unless file generation is absolutely critical
}

generate_meta_json() {
  local dir=$1 tech=$2 class=$3 # dir is the target directory
  local entry_point=""

  case "$tech" in
    node)
      case "$class" in
        api|ui) entry_point="src/index.ts" ;; 
        lib) entry_point="src/index.ts" ;;
        cli) entry_point="src/cli.ts" ;; 
        *) log "⚠️ Unknown node class: $class for meta entry point"; entry_point="src/index.js" ;; 
      esac
      ;;
    rust)
      case "$class" in
        agent|api|cli) entry_point="src/main.rs" ;; 
        lib) entry_point="src/lib.rs" ;;         
        *) log "⚠️ Unknown rust class: $class for meta entry point"; entry_point="src/main.rs" ;; 
      esac
      ;;
    go)
      case "$class" in
        agent|api|cli) entry_point="main.go" ;; 
        lib) entry_point="lib.go" ;;        
        *) log "⚠️ Unknown go class: $class for meta entry point"; entry_point="main.go" ;; 
      esac
      ;;
    *) log "⚠️ Unknown tech: $tech for meta entry point" ;;
  esac

  # Use jq to create formatted JSON in the target directory
  # Note: $dir should be the absolute path or relative to where jq is run
  if jq -n \
    --arg tech "$tech" \
    --arg class "$class" \
    --arg entry "$entry_point" \
    '{ tech: $tech, class: $class, entry: $entry }' > "$dir/.metadata.json"; then
    log_info "📝 Generated .metadata.json in $dir for $tech $class project"
  else
    log_error "❌ Failed to generate .metadata.json in $dir"
    return 1 # Indicate failure
  fi
}

# Get script directory (assuming scaffolding.sh is in functions/)
# SCRIPT_DIR needs to be defined in the main bootstrap.sh or passed
# For now, assuming SCRIPT_DIR is available globally or adjust as needed.

# Process templates based on a metadata.json manifest in the template source dir
process_templates() {
  local dir=$1 # Target project directory (passed correctly)
  local tech=$2
  local class=$3
  # Framework argument needed later for UI projects
  # local framework=$4 
  
  # Construct path to the template manifest
  # Assumes SCRIPT_DIR points to the main script's dir (dev-setup/)
  local meta_file="$SCRIPT_DIR/bootstrap/templates/$tech/$class/metadata.json"
  
  log_info "📁 Processing templates using manifest: $meta_file"
  log_info "   Target directory: $dir"
  
  if [[ ! -f "$meta_file" ]]; then
    log_error "❌ Template manifest file not found: $meta_file"
    # Decide if this is a fatal error or just a warning
    return 1 # Returning error for now
  fi
  
  # Read variables needed for templates (can be extended)
  local project_name
  project_name=$(basename "$dir") # Use target directory name as project name
  local version="1.0.0"         # Default version
  local port="3000"             # Default port (for node api/ui)
  local description="A $tech $class project" # Add description
  
  # Calculate entry_point based on tech/class (same logic as generate_meta_json)
  local entry_point=""
  case "$tech" in
    node)
      case "$class" in
        api|ui|lib) entry_point="index" ;; # Just the basename, .ts is assumed later
        cli) entry_point="cli" ;; 
        *) log_warning "⚠️ Unknown node class: $class for entry point calculation"; entry_point="index" ;; 
      esac
      ;;
    rust)
      case "$class" in
        agent|api|cli) entry_point="main" ;; # Just the basename
        lib) entry_point="lib" ;;         
        *) log_warning "⚠️ Unknown rust class: $class for entry point calculation"; entry_point="main" ;; 
      esac
      ;;
    go)
      case "$class" in
        agent|api|cli) entry_point="main" ;; # Just the basename
        lib) entry_point="lib" ;;        
        *) log_warning "⚠️ Unknown go class: $class for entry point calculation"; entry_point="main" ;; 
      esac
      ;;
    *) log_warning "⚠️ Unknown tech: $tech for entry point calculation" ;;
  esac
  
  log_info "   Project name variable: $project_name"
  log_info "   Entry point variable: $entry_point"
  
  # Process each file entry defined in the template metadata.json
  # Using jq to iterate over the '.files' array
  jq -c '.files[]' "$meta_file" | while IFS= read -r file_entry; do
    local path
    local template
    local vars_json
    
    # Safely extract values using jq
    path=$(echo "$file_entry" | jq -r '.path // empty')
    template=$(echo "$file_entry" | jq -r '.template // empty')
    vars_json=$(echo "$file_entry" | jq -c '.variables // []') # Get variables as a JSON array
    
    # Skip if essential info is missing
    if [[ -z "$path" || -z "$template" ]]; then
        log_warning "⚠️ Skipping invalid file entry in $meta_file: $file_entry"
        continue
    fi

    local template_source_path="$SCRIPT_DIR/bootstrap/templates/$tech/$class/$template"
    local output_target_path="$dir/$path"
    
    # Special handling for Docker files - keep them in a docker subdirectory
    if [[ "$template" == *"docker/"* ]]; then
        # Ensure docker subdirectory exists
        mkdir -p "$dir/docker"
        # If the output is going to root, redirect to docker subdirectory
        if [[ "$(dirname "$path")" == "." ]]; then
            output_target_path="$dir/docker/$(basename "$path")"
            log_info "      -> Docker file redirected to docker subdirectory: $output_target_path"
        fi
    fi
    
    log_info "   📄 Processing template: $template_source_path -> $output_target_path"
    
    # Build variables string for process_template function
    local var_string=""
    local var
    # Read variables from the JSON array
    while IFS= read -r var; do
      # Remove quotes added by jq -c
      local clean_var=${var//\"/}
      case "$clean_var" in
        project_name) var_string+="project_name=$project_name " ;;
        version) var_string+="version=$version " ;;
        port) var_string+="port=$port " ;;
        description) var_string+="description=$description " ;; # Add description variable
        entry_point) var_string+="entry_point=$entry_point " ;; # Add entry_point variable
        # Add more potential variables here
        *) log_warning "   -> Ignoring unknown variable '$clean_var' defined in metadata.json" ;;
      esac
    done < <(echo "$vars_json" | jq -r '.[]') # Use jq -r to get raw strings
    
    log_info "      -> Variables: ${var_string:-<none>}"
    
    # Call the helper to copy and process the single template file
    process_template "$template_source_path" "$output_target_path" "$var_string"
  done
  
  # Check exit status of jq pipe - important for catching parsing errors
  local pipe_status=${PIPESTATUS[0]}
  if [[ $pipe_status -ne 0 ]]; then
      log_error "❌ Error processing template manifest $meta_file (jq exit status: $pipe_status)"
      return 1
  fi

  log_info "   ✅ Finished processing templates from $meta_file"
  
  # --- Generate .env file --- #
  # Place it in the docker subdirectory so docker-compose -f finds it
  local env_file="$dir/docker/.env"
  log_info "   📝 Generating default .env file: $env_file"
  # Ensure the docker directory exists first
  mkdir -p "$dir/docker"
  # Define default variables - port is needed by docker-compose
  cat << EOF > "$env_file"
# Environment variables for $project_name (used by docker-compose)
port=$port
# Add other environment variables as needed
EOF
  if [[ $? -ne 0 ]]; then
      log_error "   ❌ Failed to generate .env file: $env_file"
      # Decide if this is fatal
  else
      log_success "   ✅ Generated .env file."
  fi
  # --- End Generate .env file ---

  return 0
}

# Process a single template file: copy and substitute variables
process_template() {
  local template_source=$1
  local output_target=$2 # Already absolute/correct path
  local vars_string=$3 # Space-separated "key=value" pairs
  
  # log "      -> Processing file: $template_source -> $output_target"
  
  if [[ ! -f "$template_source" ]]; then
    log_error "      ❌ Template source file not found: $template_source"
    return 1
  fi
  
  # Create output directory if it doesn't exist
  local output_dir
  output_dir=$(dirname "$output_target")
  if ! mkdir -p "$output_dir"; then
     log_error "      ❌ Failed to create output directory: $output_dir"
     return 1
  fi
  
  # Copy template to output location
  if ! cp "$template_source" "$output_target"; then
     log_error "      ❌ Failed to copy template $template_source to $output_target"
     return 1
  fi
  # log "      -> Copied template to output"
  
  # Substitute basic placeholders using sed
  # Loop through the key=value pairs in vars_string
  local kv_pair
  local key
  local value
  for kv_pair in $vars_string; do
    # Split key=value
    key="${kv_pair%%=*}"
    value="${kv_pair#*=}"
    
    # Check if key is non-empty to avoid issues
    if [[ -n "$key" ]]; then
      # log "      -> Replacing {{${key}}} with ${value}"
      # Handle {{variable}} style templates (common in most templates)
      if ! sed -i '' "s|{{${key}}}|${value}|g" "$output_target"; then
          log_error "      ❌ Failed to substitute {{${key}}} in $output_target"
          # Decide whether to continue or return error
      fi
      
      # Also handle ${variable} style templates (used in package.json.tpl)
      if ! sed -i '' "s|\\\${${key}}|${value}|g" "$output_target"; then
          log_error "      ❌ Failed to substitute \${${key}} in $output_target"
          # Decide whether to continue or return error
      fi
    fi
  done

  # Special handling for package.json dependencies - Consider moving this
  # into a separate function or handling it during merge phase for UI
  if [[ "$template_source" == *"package.json.tpl" ]]; then
    log_info "      -> Performing package.json specific substitutions..."
    # This is basic and might be insufficient for complex package.json generation
    # Consider using jq for more robust package.json manipulation later
    local express_version=$(get_latest_version express)
    local types_express_version=$(get_latest_version @types/express)
    local types_node_version=$(get_latest_version @types/node)
    local typescript_version=$(get_latest_version typescript)
    local tsx_version=$(get_latest_version tsx)
    local vitest_version=$(get_latest_version vitest)
    local biome_version=$(get_latest_version @biomejs/biome)

    sed -i '' "s|{{dependencies.express}}|^${express_version}|g" "$output_target"
    sed -i '' "s|{{devDependencies.@types/express}}|^${types_express_version}|g" "$output_target"
    sed -i '' "s|{{devDependencies.@types/node}}|^${types_node_version}|g" "$output_target"
    sed -i '' "s|{{devDependencies.typescript}}|^${typescript_version}|g" "$output_target"
    sed -i '' "s|{{devDependencies.tsx}}|^${tsx_version}|g" "$output_target"
    sed -i '' "s|{{devDependencies.vitest}}|^${vitest_version}|g" "$output_target"
    sed -i '' "s|{{devDependencies.biome}}|^${biome_version}|g" "$output_target"
    # Remove potentially unused placeholders if any remain
    sed -i '' 's/{{[^{}]*}}//g' "$output_target"
    # Also handle any remaining ${variable} placeholders - use double backslash to escape $ for sed
    sed -i '' 's/\${[^}]*}//g' "$output_target"

  fi
  
  return 0
} 
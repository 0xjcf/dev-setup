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

format:
  pnpm biome check --write .

build:
  pnpm build

# --- Docker Commands ---
# Build the docker image (using Dockerfile in ./docker/)
docker-build:
  docker build -t $project_name -f docker/Dockerfile .

# Run the application in docker-compose (detached, using compose file in ./docker/)
docker-dev:
  @docker compose -f docker/docker-compose.yml up --build -d api
  @echo "Container started in detached mode. Following logs (Ctrl+C to stop logs)..."
  @docker compose -f docker/docker-compose.yml logs --follow api

# Run tests within the docker container (using compose file in ./docker/)
docker-test:
  @docker compose -f docker/docker-compose.yml run --rm api pnpm test

# Stop docker-compose services (using compose file in ./docker/)
docker-stop:
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
# --- Docker Commands (Example) ---
# Build the docker image (Dockerfile often Multi-stage for UI)
docker-build:
  docker build -t $project_name -f docker/Dockerfile .

docker-dev:
  @echo "INFO: Running UI dev server often done locally via 'just dev'"
  @echo "INFO: If using Docker, ensure docker-compose.yml exposes ports."
  # @docker compose -f docker/docker-compose.yml up --build -d # Example

docker-test:
  @echo "INFO: Running UI tests often done locally via 'just test'"
  # @docker compose -f docker/docker-compose.yml run --rm ui pnpm test # Example

docker-stop:
  # @docker compose -f docker/docker-compose.yml down # Example
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
      # Use heredoc pattern for Rust cases
      case "$class" in
        agent)
          cat << EOF > "$justfile_path"
# Rust Agent project tasks
default:
  @just --list

dev:
  @cargo run

test:
  @cargo nextest run # Use nextest if available

lint:
  @cargo clippy --all-targets -- -D warnings

build:
  @cargo build --release

# --- Docker Commands ---
docker-build:
  @docker build -t $project_name -f docker/Dockerfile .

docker-dev:
  @docker compose -f docker/docker-compose.yml up --build -d
  @echo "Container started in detached mode. Following logs (Ctrl+C to stop logs)..."
  @docker compose -f docker/docker-compose.yml logs --follow dev

docker-test:
  @echo "Docker tests not typically run for agents this way."

docker-stop:
  @docker compose -f docker/docker-compose.yml down
EOF
          ;;
        api)
          cat << EOF > "$justfile_path"
# Rust API project tasks
default:
  @just --list

dev:
  @cargo run

test:
  @cargo nextest run

lint:
  @cargo clippy --all-targets -- -D warnings

build:
  @cargo build --release

# --- Docker Commands ---
docker-build:
  @docker build -t $project_name -f docker/Dockerfile .

docker-dev:
  @docker compose -f docker/docker-compose.yml up --build -d
  @echo "Container started in detached mode. Following logs (Ctrl+C to stop logs)..."
  @docker compose -f docker/docker-compose.yml logs --follow dev

docker-test:
  @echo "Docker tests not implemented for Rust API yet."
  # @docker compose -f docker/docker-compose.yml run --rm $project_name cargo nextest run

docker-stop:
  @docker compose -f docker/docker-compose.yml down
EOF
          ;;
        cli)
          cat << EOF > "$justfile_path"
# Rust CLI project tasks
default:
  @just --list

dev:
  @cargo run -- --help # Example: run with help flag

test:
  @cargo nextest run

lint:
  @cargo clippy --all-targets -- -D warnings

build:
  @cargo build --release

install:
  @cargo install --path .
EOF
          ;;
        lib)
          cat << EOF > "$justfile_path"
# Rust Library project tasks
default:
  @just --list

test:
  @cargo nextest run

lint:
  @cargo clippy --all-targets -- -D warnings

build:
  @cargo build --release

publish:
  # Ensure you are logged in: cargo login [token]
  @cargo publish
EOF
          ;;
        *)
          log_warning "⚠️ No specific Rust justfile template found for class $class"
          cat << EOF > "$justfile_path"
# Default tasks for Rust project
default:
  @just --list
EOF
          ;;
      esac
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

# Get script directory (assuming scaffolding.sh is in functions/)
# SCRIPT_DIR needs to be defined in the main bootstrap.sh or passed
# For now, assuming SCRIPT_DIR is available globally or adjust as needed.

# Process templates based on a metadata.json manifest in the template source dir
process_templates() {
  local dir="$1"
  local tech="$2"
  local class="$3"
  local framework="$4" # Capture framework if passed (for UI projects)
  
  log_header "Processing Templates"
  log_info "Directory: $dir"
  log_info "Technology: $tech"
  log_info "Class: $class"
  [[ -n "$framework" ]] && log_info "Framework: $framework"
  
  # --- Update package.json lint script FIRST if it exists ---
  # This needs to happen before template processing might overwrite package.json
  # or before finalize steps run install/lint
  local target_pkg_json="$dir/package.json"
  if [[ -f "$target_pkg_json" && ("$tech" == "node" || "$tech" == "electron") ]]; then
      log_info "Found package.json in target. Updating lint script to use Biome..."
      # Use jq to update the scripts.lint entry. Create scripts object if it doesn't exist.
      # Read file, update, write to temp, then move temp to original
      local temp_pkg_json="${target_pkg_json}.tmp"
      if run_or_dry jq '( .scripts.lint = "biome check ." )' "$target_pkg_json" > "$temp_pkg_json" && run_or_dry mv "$temp_pkg_json" "$target_pkg_json"; then
          log_success "Successfully updated package.json lint script."
      else
          log_warning "Failed to update package.json lint script using jq. Linting might not work as expected."
          # Clean up temp file if mv failed
          [ -f "$temp_pkg_json" ] && run_or_dry rm "$temp_pkg_json"
      fi
  fi
  # --- END package.json update ---

  # Determine template source directory based on tech and class
  # Base path without framework consideration first
  local template_base_dir="$SCRIPT_DIR/../bootstrap/templates/$tech/$class"
  local meta_file="$template_base_dir/metadata.json"
  local use_framework_templates=false

  # For UI projects with frameworks, check if we need to use a framework-specific path
  if [[ "$class" == "ui" && -n "$framework" ]]; then
    # Construct the framework-specific path
    local framework_template_base_dir="$SCRIPT_DIR/../bootstrap/templates/$tech/$framework"
    local framework_meta_file="$framework_template_base_dir/metadata.json"
    
    # Check if framework-specific templates exist (check for the metadata file)
    if [[ -f "$framework_meta_file" ]]; then
      meta_file="$framework_meta_file"
      template_base_dir="$framework_template_base_dir"
      use_framework_templates=true
      log_info "📁 Using framework-specific templates: $template_base_dir"
    else
      log_info "Framework-specific templates not found at $framework_template_base_dir. Using base $tech/$class templates."
    fi
  fi

  # Now, check if the selected meta_file exists
  if [[ ! -f "$meta_file" ]]; then
    log_info "No template manifest found at $meta_file. Skipping template processing."
    # If we expected framework templates but didn't find them, maybe fall back?
    # For now, just skip if the selected meta_file doesn't exist.
    return 0
  fi

  log_info "📁 Processing templates using manifest: $meta_file"
  log_info "   Target directory: $dir"
  
  # Read variables needed for templates (can be extended)
  local project_name
  project_name=$(basename "$dir") # Use target directory name as project name
  local version="1.0.0"         # Default version
  local port="3000"             # Default port (for node api/ui)
  local description="A $tech $class project" # Add description
  [[ -n "$framework" ]] && description="A $framework $tech $class project"

  # Calculate entry_point based on tech/class
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
  if ! jq -c '.files[]' "$meta_file" | while IFS= read -r file_entry; do
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

    # Use template_base_dir instead of hardcoded path
    local template_source_path="$template_base_dir/$template"
    local output_target_path="$dir/$path"

    # --- Skip Check ---
    # If the target file already exists (likely created by a base scaffolder like create-next-app),
    # skip processing specific config files to avoid overwriting potentially fine-tuned versions.
    if [[ -f "$output_target_path" ]]; then
      case "$path" in
        # Add globals.css to the list of files to preserve if generated by create-next-app
        tailwind.config.ts|postcss.config.mjs|next.config.mjs|next.config.ts|src/app/globals.css)
          log_debug "   -> Skipping template processing for existing config/core file: $output_target_path"
          continue # Skip to the next file in the loop
          ;;
      esac
    fi
    # --- End Skip Check ---
    
    # Special handling for Docker files - keep them in a docker subdirectory
    # Skip this entirely for rust/cli projects
    if ! [[ "$tech" == "rust" && "$class" == "cli" ]]; then
      if [[ "$template" == *"docker/"* || "$path" == "Dockerfile" || "$path" == "docker-compose.yml" ]]; then
          # Ensure docker subdirectory exists
          run_or_dry mkdir -p "$dir/docker"
          # If the output is going to root, redirect to docker subdirectory
          if [[ "$(dirname "$path")" == "." ]]; then
              output_target_path="$dir/docker/$(basename "$path")"
              log_debug "      -> Docker file redirected to docker subdirectory: $output_target_path"
          else
              # If the path already includes 'docker/', ensure the parent dir exists
              run_or_dry mkdir -p "$(dirname "$output_target_path")"
          fi
      else
          # Ensure the parent directory exists for non-docker files
          run_or_dry mkdir -p "$(dirname "$output_target_path")"
      fi
    else # rust/cli case
        # Ensure the parent directory exists for non-docker files
        run_or_dry mkdir -p "$(dirname "$output_target_path")"
    fi
    
    log_debug "   📄 Processing template: $template_source_path -> $output_target_path"
    
    # Build variables string for process_template function
    local var_string=""
    local var
    # Read variables from the JSON array
    while IFS= read -r var; do
      # Remove quotes added by jq -r
      local clean_var=${var//\"/}
      case "$clean_var" in
        project_name) var_string+="project_name=$project_name " ;; 
        version) var_string+="version=$version " ;; 
        port) var_string+="port=$port " ;; 
        description) var_string+="description=$description " ;; # Don't add quotes here, template should have them
        entry_point) var_string+="entry_point=$entry_point " ;; 
        # Add more potential variables here
        *) log_warning "   -> Ignoring unknown variable '$clean_var' defined in metadata.json" ;;
      esac
    done < <(echo "$vars_json" | jq -r '.[]') # Use jq -r to get raw strings
    
    log_debug "      -> Variables: ${var_string:-<none>}"
    
    # Call the helper to copy and process the single template file
    process_template "$template_source_path" "$output_target_path" "$var_string"
  done; then
      # Check exit status of the pipeline (specifically the while loop or process_template inside)
      # PIPESTATUS only works directly after the pipeline
      log_error "❌ Error occurred during template file processing loop for $meta_file"
      return 1
  fi

  log_info "   ✅ Finished processing templates from $meta_file"
  
  # --- Generate .env file --- #
  # Skip for rust/cli projects
  if ! [[ "$tech" == "rust" && "$class" == "cli" ]]; then
    # Place it in the docker subdirectory so docker-compose -f finds it
    local env_file="$dir/docker/.env"
    log_debug "   📝 Generating default .env file: $env_file"
    # Ensure the docker directory exists first
    run_or_dry mkdir -p "$dir/docker"
    # Define default variables - port is needed by docker-compose
    # Use printf for better control over format and avoid issues with content
    if ! run_or_dry printf '%s\n' "# Environment variables for $project_name (used by docker-compose)" "port=$port" "# Add other environment variables as needed" > "$env_file"; then
        log_error "  Failed to generate .env file: $env_file"
        # Decide if this is fatal
    else
        log_debug "Generated .env file."
    fi
  fi
  # --- End Generate .env file ---

  return 0
}

# Helper function to process a single template file
# Copies the file and replaces placeholders like {{variable_name}}
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
    log_debug "      -> Performing package.json specific substitutions..."
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
  fi
  
  return 0
} 
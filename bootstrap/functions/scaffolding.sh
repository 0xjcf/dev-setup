#!/bin/bash

# Scaffolding helper functions

# Ensure utils are sourced first if helpers depend on them (like log)
# Consider adding: source "$(dirname "$0")/../utils/common.sh" if needed standalone

generate_justfile() {
  local tech=$1 class=$2
  local justfile_content=""

  # Determine content based on tech and class
  case "$tech" in
    node)
      # ... Node.js justfile content ... 
      case "$class" in
        api)
          justfile_content="
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
"
          ;;
        ui)
          justfile_content="
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
"
          ;;
        lib)
          justfile_content="
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
"
          ;;
        cli)
          justfile_content="
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
"
          ;;
      esac
      ;;
    rust)
       # ... Rust justfile content ...
      case "$class" in
        agent) # Assuming 'agent' maps to some generic Rust tasks
          justfile_content="
# Rust Agent project tasks
default:
  @just --list

dev:
  cargo run

test:
  cargo test

lint:
  cargo clippy

build:
  cargo build --release
"
          ;;
        api)
          justfile_content="
# Rust API project tasks
default:
  @just --list

dev:
  cargo run

test:
  cargo test

lint:
  cargo clippy

build:
  cargo build --release
"
          ;;
        cli)
          justfile_content="
# Rust CLI project tasks
default:
  @just --list

dev:
  cargo run

test:
  cargo test

lint:
  cargo clippy

build:
  cargo build --release

install:
  cargo install --path .
"
          ;;
        lib)
          justfile_content="
# Rust Library project tasks
default:
  @just --list

test:
  cargo test

lint:
  cargo clippy

build:
  cargo build --release

publish:
  cargo publish
"
          ;;
      esac
      ;;
    go)
      # ... Go justfile content ...
      case "$class" in
        api)
          justfile_content="
# Go API project tasks
default:
  @just --list

dev:
  go run main.go

test:
  go test ./...

lint:
  golangci-lint run

build:
  go build -o bin/api
"
          ;;
        cli)
          justfile_content="
# Go CLI project tasks
default:
  @just --list

dev:
  go run main.go

test:
  go test ./...

lint:
  golangci-lint run

build:
  go build -o bin/cli

install:
  go install
"
          ;;
        lib)
          justfile_content="
# Go Library project tasks
default:
  @just --list

test:
  go test ./...

lint:
  golangci-lint run

build:
  go build ./...
"
          ;;
        agent)
          justfile_content="
# Go Agent project tasks
default:
  @just --list

dev:
  go run main.go

test:
  go test ./...

lint:
  golangci-lint run

build:
  go build -o bin/agent
"
          ;;
      esac
      ;;
  esac

  if [ -n "$justfile_content" ]; then
    echo "$justfile_content" > justfile
    log "📝 Generated justfile for $tech $class project"
  else
    log "⚠️ No justfile template found for $tech/$class"
  fi
}

generate_meta_json() {
  local dir=$1 tech=$2 class=$3
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
    '{ tech: $tech, class: $class, entry: $entry }' > "$dir/.meta.json"; then
    log "📝 Generated .meta.json in $dir for $tech $class project"
  else
    log "❌ Failed to generate .meta.json in $dir"
    return 1 # Indicate failure
  fi
}

# Get script directory (assuming scaffolding.sh is in functions/)
# SCRIPT_DIR needs to be defined in the main bootstrap.sh or passed
# For now, assuming SCRIPT_DIR is available globally or adjust as needed.

# Process templates based on a meta.json manifest in the template source dir
process_templates() {
  local dir=$1 # Target project directory
  local tech=$2
  local class=$3
  # Framework argument needed later for UI projects
  # local framework=$4 
  
  # Construct path to the template manifest
  # Assumes SCRIPT_DIR points to the main script's dir (dev-setup/)
  local meta_file="$SCRIPT_DIR/templates/$tech/$class/meta.json"
  
  log "📁 Processing templates using manifest: $meta_file"
  log "   Target directory: $dir"
  
  if [[ ! -f "$meta_file" ]]; then
    log "❌ Template manifest file not found: $meta_file"
    # Decide if this is a fatal error or just a warning
    return 1 # Returning error for now
  fi
  
  # Read variables needed for templates (can be extended)
  local project_name
  project_name=$(basename "$dir") # Use target directory name as project name
  local version="1.0.0"         # Default version
  local port="3000"             # Default port (for node api/ui)
  
  log "   Project name variable: $project_name"
  
  # Process each file entry defined in the template meta.json
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
        log "⚠️ Skipping invalid file entry in $meta_file: $file_entry"
        continue
    fi

    local template_source_path="$SCRIPT_DIR/templates/$tech/$class/$template"
    local output_target_path="$dir/$path"
    
    log "   📄 Processing template: $template_source_path -> $output_target_path"
    
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
        # Add more potential variables here
        *) log "   -> Ignoring unknown variable '$clean_var' defined in meta.json" ;;
      esac
    done < <(echo "$vars_json" | jq -r '.[]') # Use jq -r to get raw strings
    
    log "      -> Variables: ${var_string:-<none>}"
    
    # Call the helper to copy and process the single template file
    process_template "$template_source_path" "$output_target_path" "$var_string"
  done
  
  # Check exit status of jq pipe - important for catching parsing errors
  local pipe_status=${PIPESTATUS[0]}
  if [[ $pipe_status -ne 0 ]]; then
      log "❌ Error processing template manifest $meta_file (jq exit status: $pipe_status)"
      return 1
  fi

  log "   -> Finished processing templates from $meta_file"
  return 0
}

# Process a single template file: copy and substitute variables
process_template() {
  local template_source=$1
  local output_target=$2
  local vars_string=$3 # Space-separated "key=value" pairs
  
  # log "      -> Processing file: $template_source -> $output_target"
  
  if [[ ! -f "$template_source" ]]; then
    log "      ❌ Template source file not found: $template_source"
    return 1
  fi
  
  # Create output directory if it doesn't exist
  local output_dir
  output_dir=$(dirname "$output_target")
  if ! mkdir -p "$output_dir"; then
     log "      ❌ Failed to create output directory: $output_dir"
     return 1
  fi
  
  # Copy template to output location
  if ! cp "$template_source" "$output_target"; then
     log "      ❌ Failed to copy template $template_source to $output_target"
     return 1
  fi
  # log "      -> Copied template to output"
  
  # Substitute basic {{variable}} placeholders using sed
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
      # Use a different delimiter for sed in case value contains slashes
      # Need to escape special characters in value for sed if necessary
      if ! sed -i '' "s|{{${key}}}|${value}|g" "$output_target"; then
          log "      ❌ Failed to substitute {{${key}}} in $output_target"
          # Decide whether to continue or return error
      fi
    fi
  done

  # Special handling for package.json dependencies - Consider moving this
  # into a separate function or handling it during merge phase for UI
  if [[ "$template_source" == *"package.json.tpl" ]]; then
    log "      -> Performing package.json specific substitutions..."
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

  fi
  
  return 0
} 
#!/bin/bash

# Template processing functions for bootstrap scripts

# ------------------------------------------------------
# Template Setup
# ------------------------------------------------------

setup_templates() {
    local project_type="$1"
    local project_dir="$2"
    local templates_dir="$3"
    local vars_to_substitute_string="$4" # Accept the key=value string
    
    info "Setting up templates for $project_type project"
    
    # Validate templates directory
    validate_dir_exists "$templates_dir" || return 1
    
    # Load metadata
    local metadata_file="$templates_dir/metadata.json"
    validate_file_exists "$metadata_file" || return 1
    
    # Process templates
    jq -c '.files[]' "$metadata_file" | while IFS= read -r file_entry; do
        local path=$(echo "$file_entry" | jq -r '.path')
        local template=$(echo "$file_entry" | jq -r '.template')
        local template_file="$templates_dir/$template"
        local target_file="$project_dir/$path"
        # Determine if substitution is needed *at all* based on whether the 'variables' array exists and is not empty in metadata
        local needs_substitution=$(echo "$file_entry" | jq -e 'has("variables") and (.variables | length > 0)')
        
        if [ -f "$template_file" ]; then
            # Ensure output directory exists before copying/processing
            mkdir -p "$(dirname "$target_file")"

            if [[ "$needs_substitution" == "true" ]]; then
                 # Pass the *full* key=value string received by the function
                if ! process_template_envsubst "$template_file" "$target_file" "$vars_to_substitute_string"; then
                    error "Failed to process template with envsubst: $template_file"
                    return 1
                fi
            else
                # If no variables listed for this template in metadata, just copy
                if ! cp "$template_file" "$target_file"; then
                    error "Failed to copy template (no vars listed): $template_file"
                    return 1
                fi
            fi
        else
            error "Template file not found: $template_file"
            return 1
        fi
    done
    # Check the exit status of the 'while' loop pipeline (jq | while)
    local pipeline_status=${PIPESTATUS[1]}
    if [ $pipeline_status -ne 0 ]; then
        error "Template processing loop failed."
        return 1
    fi
    
    success "Templates processed successfully"
    return 0
}

# ------------------------------------------------------
# Template Validation
# ------------------------------------------------------

validate_template() {
    local template_file="$1"
    local required_vars=("$2")
    
    # Check if template file exists
    validate_file_exists "$template_file" || return 1
    
    # Check for required variables
    for var in "${required_vars[@]}"; do
        # Check for {{var}} or $var or ${var} patterns
        if ! grep -q -e "{{\?$var\?}}" -e "\$$var" -e "\${$var}" "$template_file"; then
            error "Template $template_file is missing required variable placeholder: $var"
            return 1
        fi
    done
    
    return 0
}

# ------------------------------------------------------
# Template Versioning
# ------------------------------------------------------

check_template_versions() {
    local templates_dir="$1"
    local metadata_file="$templates_dir/metadata.json"
    
    info "Checking template versions"
    
    # Check package.json template
    if [ -f "$templates_dir/package.json.tpl" ]; then
        local deps=$(jq -r '.dependencies + .devDependencies | keys[]' "$templates_dir/package.json.tpl")
        for dep in $deps; do
            local version=$(jq -r ".dependencies[\"$dep\"] // .devDependencies[\"$dep\"]" "$templates_dir/package.json.tpl")
            check_version "$dep" "$version"
        done
    fi
    
    return 0
}

check_version() {
    local package="$1"
    local version="$2"
    
    # Get latest version from npm
    local latest=$(pnpm info "$package" version)
    
    if [ "$version" != "$latest" ]; then
        warn "Package $package is outdated: $version (latest: $latest)"
    fi
}

# ------------------------------------------------------
# Template Extraction
# ------------------------------------------------------

extract_template_section() {
    local template_file="$1"
    local section_name="$2"
    local output_file="$3"
    
    info "Extracting section '$section_name' from $template_file"
    
    # Create output directory if it doesn't exist
    mkdir -p "$(dirname "$output_file")"
    
    # Extract section between markers
    awk "/#### $section_name/{p=1;next} /^```typescript$/{if(p){p=2;next}} /^```$/{if(p==2){p=0}} p==2{print}" "$template_file" > "$output_file"
    
    # Check if extraction was successful
    if [ ! -s "$output_file" ]; then
        error "Failed to extract section '$section_name' from template"
        return 1
    fi
    
    success "Successfully extracted section '$section_name'"
    return 0
}

# Simplified function using envsubst (No specific var list)
process_template_envsubst() {
    local template_file="$1"
    local output_file="$2"
    local vars_string="$3" # Format: key=value\nkey=value...

    # Ensure output directory exists
    mkdir -p "$(dirname "$output_file")"

    # Check if envsubst exists
    if ! command -v envsubst &> /dev/null; then
        error "envsubst command not found. Please install gettext package."
        return 1
    fi

    # Create a subshell to isolate exported variables
    (
        # Export variables defined in vars_string using process substitution
        while IFS='=' read -r key value; do
            # Basic sanitation for key (simple alphanumeric + underscore)
            if [[ -n "$key" && "$key" =~ ^[a-zA-Z0-9_]+$ ]]; then
                 # debug "Exporting for envsubst: $key=$value" # Optional debug log
                export "$key=$value"
            elif [[ -n "$key" ]]; then # Only warn if key is not empty but invalid
                warn "Skipping invalid variable key for export: $key"
            fi
        done < <(echo -e "$vars_string") # Use process substitution here

        # Perform substitution - envsubst (no args) substitutes all exported vars found in template
        # debug "Running: envsubst < \"$template_file\" > \"$output_file\"" # Optional debug log
        envsubst < "$template_file" > "$output_file"

    ) # Subshell ends, exported variables are unset
    local status=$?

    # Check envsubst status
    if [ $status -ne 0 ]; then
        error "envsubst failed for template: $template_file with status $status"
        return 1
    fi

    # Ensure the output file was created and is not empty (important!)
    if [ ! -s "$output_file" ]; then
        error "Failed to create or generated empty output file: $output_file using template $template_file"
        return 1
    fi
    # debug "Substituted: $template_file -> $output_file" # Optional debug log

    return 0
}
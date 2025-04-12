#!/bin/bash

# Configuration functions
validate_monorepo_json() {
  local file=$1
  if [ ! -f "$file" ]; then
    echo "❌ Config file not found: $file"
    return 1
  fi

  # Check if file is valid JSON
  if ! jq empty "$file" >/dev/null 2>&1; then
    echo "❌ Invalid JSON in config file: $file"
    return 1
  fi

  # Validate schema
  local valid=$(jq '
    .projects | if type == "array" then
      all(
        .[] |
        has("path") and
        has("type") and
        has("class") and
        .type | inside(["node", "rust", "go"]) and
        .class | inside({
          "node": ["api", "ui", "lib", "cli"],
          "rust": ["agent", "api", "cli", "lib"],
          "go": ["api", "cli", "lib", "agent"]
        }[.type])
      )
    else false end
  ' "$file")

  if [ "$valid" != "true" ]; then
    echo "❌ Invalid schema in config file: $file"
    return 1
  fi

  return 0
}

load_from_config() {
  local file=$1
  if [ -n "$file" ]; then
    if validate_monorepo_json "$file"; then
      echo "📋 Loading configuration from $file"
      jq -c '.projects[]' "$file" | while read -r project; do
        local path=$(echo "$project" | jq -r '.path')
        local tech=$(echo "$project" | jq -r '.type')
        local class=$(echo "$project" | jq -r '.class')
        
        echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 Processing project from config:"
        echo "📁 Path: $path"
        echo "🛠  Tech: $tech"
        echo "📝 Type: $class"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        run_bootstrap_for_dir "$path" "$tech" "$class"
      done
      exit 0
    else
      echo "❌ Failed to load configuration from $file"
      exit 1
    fi
  fi
}

write_monorepo_json() {
  local path=$1 type=$2 class=$3
  [[ ! -f .monorepo.json ]] && echo '{ "projects": [] }' > .monorepo.json
  if ! grep -q "\"path\": \"$path\"" .monorepo.json; then
    tmp=$(mktemp)
    jq ".projects += [{\"path\": \"$path\", \"type\": \"$type\", \"class\": \"$class\"}]" .monorepo.json > "$tmp" && mv "$tmp" .monorepo.json
    echo "📦 Added '$path' to .monorepo.json as { type: $type, class: $class }"
  fi
} 
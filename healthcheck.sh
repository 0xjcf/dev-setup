#!/bin/bash

set -e

QUIET=false
JSON=false

for arg in "$@"; do
  case $arg in
    --quiet) QUIET=true ;;
    --json) JSON=true ;;
  esac
done

if $JSON; then
  OUTPUT="{"
else
  $QUIET || echo "💥 Running Jose's Dev Stack Health Check..."
fi

FAIL=0

check_tool() {
  local name="$1"
  local command="$2"

  if command -v "$command" &>/dev/null; then
    $JSON && OUTPUT+="\n  \"$name\": \"ok\"," || $QUIET || echo "✅ $name is installed"
  else
    $JSON && OUTPUT+="\n  \"$name\": \"fail\"," || $QUIET || echo "❌ $name is NOT installed"
    FAIL=1
  fi
}

check_rust_component() {
  local name="$1"
  if rustup component list --installed 2>/dev/null | grep -q "$name"; then
    $JSON && OUTPUT+="\n  \"$name\": \"ok\"," || $QUIET || echo "✅ $name installed"
  else
    $JSON && OUTPUT+="\n  \"$name\": \"fail\"," || $QUIET || echo "❌ $name missing"
    FAIL=1
  fi
}

check_node_tool() {
  local name="$1"
  local cmd="$2"

  if command -v "$cmd" &>/dev/null; then
    local version="$($cmd --version | head -n 1)"
    $JSON && OUTPUT+="\n  \"$name\": \"ok\"," || $QUIET || echo "✅ $name: $version"
  else
    $JSON && OUTPUT+="\n  \"$name\": \"fail\"," || $QUIET || echo "❌ $name not found"
    FAIL=1
  fi
}

check_env_var() {
  local var="$1"
  local name="$2"
  local val="${!var}"

  if [[ -n "$val" && -d "$val" ]]; then
    $JSON && OUTPUT+="\n  \"$name\": \"ok\"," || $QUIET || echo "✅ $name is set to $val"
  else
    $JSON && OUTPUT+="\n  \"$name\": \"fail\"," || $QUIET || echo "❌ $name not set or invalid"
    FAIL=1
  fi
}

check_rc_sourced() {
  local name="$1"
  local pattern="$2"

  if grep -q "$pattern" ~/.zshrc 2>/dev/null; then
    $JSON && OUTPUT+="\n  \"$name\": \"ok\"," || $QUIET || echo "✅ $name sourced in .zshrc"
  else
    $JSON && OUTPUT+="\n  \"$name\": \"warn\"," || $QUIET || echo "⚠️ $name not sourced in .zshrc"
  fi
}

# Tools
check_tool "brew" "brew"
for t in bat rg fzf gh direnv just eza tokei jq glow hyperfine dive trivy semgrep zoxide lazydocker; do
  check_tool "$t" "$t"
done

# Rust
check_tool "rustc" "rustc"
check_tool "cargo" "cargo"
check_rust_component "clippy"
check_rust_component "rustfmt"

# Node + Volta
check_node_tool "node" "node"
check_node_tool "pnpm" "pnpm"
check_node_tool "volta" "volta"

# SQLite & Python
check_tool "sqlite3" "sqlite3"
if brew list sqlite &>/dev/null; then
  $JSON && OUTPUT+="\n  \"sqlite\": \"ok\"," || $QUIET || echo "✅ sqlite (library) is installed"
else
  $JSON && OUTPUT+="\n  \"sqlite\": \"fail\"," || $QUIET || echo "❌ sqlite (library) is NOT installed"
  FAIL=1
fi
check_tool "python3" "python3"

# Docker
check_tool "docker" "docker"
if docker compose version &>/dev/null; then
  $JSON && OUTPUT+="\n  \"docker_compose\": \"ok\"," || $QUIET || echo "✅ docker compose plugin available"
else
  $JSON && OUTPUT+="\n  \"docker_compose\": \"fail\"," || $QUIET || echo "❌ docker compose plugin not working"
  FAIL=1
fi

if grep -q cliPluginsExtraDirs ~/.docker/config.json 2>/dev/null; then
  $JSON && OUTPUT+="\n  \"docker_config\": \"ok\"," || $QUIET || echo "✅ Docker plugin config found"
else
  $JSON && OUTPUT+="\n  \"docker_config\": \"fail\"," || $QUIET || echo "⚠️ Docker plugin config missing"
fi

# Ollama API check
if curl -s http://localhost:11434/api/tags &>/dev/null; then
  $JSON && OUTPUT+="\n  \"ollama_service\": \"ok\"," || $QUIET || echo "✅ Ollama service is up and running"
else
  $JSON && OUTPUT+="\n  \"ollama_service\": \"fail\"," || $QUIET || echo "❌ Ollama service is not responding"
  FAIL=1
fi

check_env_var "OPENSSL_DIR" "openssl"
check_rc_sourced "cargo_env" ".cargo/env"

if $JSON; then
  # remove trailing comma and print pure JSON
  OUTPUT="${OUTPUT%,\n}\n}"
  echo -e "$OUTPUT"
elif ! $QUIET; then
  if [ "$FAIL" -eq 0 ]; then
    echo -e "\n✅ All systems go! Dev environment looks great. 💪"
  else
    echo -e "\n❌ One or more checks failed. Please fix the above before continuing."
  fi
fi

exit "$FAIL"

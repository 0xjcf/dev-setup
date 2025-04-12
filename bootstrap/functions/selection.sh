#!/bin/bash

# Selection functions
select_tech_stack() {
  echo "DEBUG: Entered select_tech_stack function"
  if [[ -n "$TECH" ]]; then
    SELECTED_OPTION="$TECH"
    echo "✅ Using tech stack: $TECH"
    return
  fi
  
  local options=("node" "rust" "go")
  if $NON_INTERACTIVE; then
    SELECTED_OPTION="node"
    echo "✅ Using default tech stack: node"
    return
  fi
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧪 Step 1: Select Technology Stack"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  select_option "Select tech stack:" "${options[@]}"
}

select_project_class() {
  local tech=$1
  if [[ -n "$CLASS" ]]; then
    SELECTED_OPTION="$CLASS"
    echo "✅ Using project class: $CLASS"
    return
  fi
  
  local options
  case "$tech" in
    node) options=("api" "ui" "lib" "cli") ;;
    rust) options=("agent" "api" "lib" "cli") ;;
    go) options=("api" "lib" "cli") ;;
  esac
  
  if $NON_INTERACTIVE; then
    SELECTED_OPTION="${options[0]}"
    echo "✅ Using default project class: ${options[0]}"
    return
  fi
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧠 Step 2: Select Project Type"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  # Use tr to capitalize first letter
  local capitalized_tech=$(echo "$tech" | tr '[:lower:]' '[:upper:]' | cut -c1)$(echo "$tech" | cut -c2-)
  select_option "Select $capitalized_tech project type:" "${options[@]}"
}

select_ui_framework() {
  local options=(
    "Next.js (Full-featured React framework with PWA support)"
    "Astro (Modern static site builder with PWA support)"
    "Vite + React (Lightweight React setup with PWA support)"
    "Remix (Full-stack framework with PWA capabilities)"
    "Lit (Web components with Lit framework)"
    "Ignite Element (Web components with lit-html and ignite-element)"
  )
  
  select_option "Select UI framework:" "${options[@]}"
  echo "$SELECTED_OPTION"
}

select_web_components_type() {
  local options=(
    "Vanilla JavaScript (Pure web components with JS)"
    "Vanilla TypeScript (Type-safe web components with TS)"
  )
  
  select_option "Select web components type:" "${options[@]}"
  echo "$SELECTED_OPTION"
}

select_state_management() {
  local options=(
    "XState (State machines and statecharts)"
    "Redux (Predictable state container)"
    "MobX (Simple, scalable state management)"
  )
  
  select_option "Select state management:" "${options[@]}"
  echo "$SELECTED_OPTION"
} 
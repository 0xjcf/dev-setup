#!/bin/bash

# setup_prompts_structure.sh
# Creates a standardized prompts directory structure for new projects

set -e

# Default values
CREATE_PLACEHOLDERS=false
DEFAULT_PHASES=("01-planning" "02-development" "03-testing" "04-deployment")
PROJECT_ROOT="."

usage() {
    echo "Usage: $0 [options] [project_root]"
    echo "Options:"
    echo "  --phases <phase_name1> [phase_name2...]  Specify phase names (e.g., --phases 01-core 02-cli)"
    echo "  --num-phases <number>                    Specify number of generic phases (e.g., --num-phases 6)"
    echo "  --create-placeholders                  Create placeholder project management files"
    echo "  -h, --help                             Display this help message"
    echo "Example: $0 --phases 01-discovery 02-build --create-placeholders ../MyNewProject"
    exit 1
}

# Parse arguments
PHASE_NAMES=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --phases)
            shift
            while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                PHASE_NAMES+=("$1")
                shift
            done
            ;;            
        --num-phases)
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                for i in $(seq 1 "$2"); do
                    PHASE_NAMES+=("$(printf "%02d-phase%d" "$i" "$i")")
                done
                shift 2
            else
                echo "Error: --num-phases requires a number."
                usage
            fi
            ;;
        --create-placeholders)
            CREATE_PLACEHOLDERS=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)\
            # Check if it's a single-letter option that might be attached to the previous one
            # This handles cases like `-h` vs potentially other options if added later
            if [[ "$1" =~ ^-[a-zA-Z]+ ]]; then
                 echo "Unknown option: $1"
                 usage
            else
                # If it's not an option starting with '-', assume it's the project root
                PROJECT_ROOT="$1"
                shift
                # If there are more arguments after this, it's an error
                if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
                    echo "Error: Project root should typically be the last argument unless using options after it."
                    usage
                fi
            fi
            ;;
        *)
            # Assume the last non-option argument is the project root
            PROJECT_ROOT="$1"
            shift
            # If there are more non-option arguments, it's an error
            if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
                 echo "Error: Only one project root argument allowed."
                 usage
            fi
            ;;
    esac
done


# Use default phases if none were provided
if [ ${#PHASE_NAMES[@]} -eq 0 ]; then
    PHASE_NAMES=("${DEFAULT_PHASES[@]}")
fi

PROMPTS_DIR="$PROJECT_ROOT/prompts"

echo "Setting up prompts directory structure in: $PROMPTS_DIR"

# Create the main directory if it doesn't exist
mkdir -p "$PROMPTS_DIR"

# Create standard subdirectories
echo "Creating standard subdirectories..."
mkdir -p "$PROMPTS_DIR/analysis"
mkdir -p "$PROMPTS_DIR/decomposition"
mkdir -p "$PROMPTS_DIR/estimation"
mkdir -p "$PROMPTS_DIR/project"
mkdir -p "$PROMPTS_DIR/templates"
mkdir -p "$PROMPTS_DIR/workflows"

# Create phase subdirectories
echo "Creating phase subdirectories..."
mkdir -p "$PROMPTS_DIR/phases"
PHASE_DIRS_LIST=""
for phase in "${PHASE_NAMES[@]}"; do
    # Sanitize phase name for directory creation (basic example)
    dir_name=$(echo "$phase" | sed 's/[^a-zA-Z0-9_-]/-/g')
    mkdir -p "$PROMPTS_DIR/phases/$dir_name"
    PHASE_DIRS_LIST+="│   ├── $dir_name/      # Phase implementation\n"
    echo "  Created: phases/$dir_name/"
done

# Create README.md with directory structure explanation
echo "Creating README.md..."
cat > "$PROMPTS_DIR/README.md" << EOF
# Project Prompts Directory

This directory contains all prompts, templates, and references used in the project. The structure is organized to make it easy to find specific types of documents.

## Directory Structure

\`\`\`
prompts/
├── analysis/         # Task analysis templates and complexity assessment guides
├── decomposition/    # Task decomposition strategies and templates
├── estimation/       # Effort estimation frameworks and references
├── phases/           # Implementation phase-specific prompts
${PHASE_DIRS_LIST}├── project/          # Project management and workflow documents
├── templates/        # Input and output templates
└── workflows/        # Process documentation and workflows
\`\`\`

## Key Files

### Project Management

- \`project/PROJECT_WORKFLOW.md\` - Development workflow guidelines and templates
- \`project/PROGRESS.md\` - Phase implementation progress tracking
- \`project/PHASE_ASSESSMENT.md\` - Assessment of phase readiness

### Implementation Phases

Each phase directory contains detailed prompts for implementing that phase.

## Using These Prompts

1. Start with the project management files to understand the overall workflow
2. Review the phase-specific prompts for implementation details
3. Use the templates and guides during development for consistent approaches

For adding new prompts, please follow the established directory structure and naming conventions.
EOF

# Conditionally create placeholder files for key project management documents
if [ "$CREATE_PLACEHOLDERS" = true ] ; then
    echo "Creating placeholder project management files..."

    # Create PROJECT_WORKFLOW.md placeholder
    if [ ! -f "$PROMPTS_DIR/project/PROJECT_WORKFLOW.md" ]; then
        cat > "$PROMPTS_DIR/project/PROJECT_WORKFLOW.md" << 'EOF'
# Project Workflow Guide

This document provides guidelines, templates, and reference information for the project development process.

## Phase Dependency Diagram

[Add phase dependency diagram here]

## Pre-Flight Checklist

[Add pre-flight checklist here]

## Development Workflow

[Add development workflow information here]

## Effort Estimation Guidelines

[Add effort estimation guidelines here]

## Phase Completion Report Template

[Add phase completion report template here]

## Issue Management

[Add issue management information here]

## Additional Resources

[Add additional resources here]
EOF
    fi

    # Create PROGRESS.md placeholder
    if [ ! -f "$PROMPTS_DIR/project/PROGRESS.md" ]; then
        PROGRESS_TABLE=""
        for i in $(seq 0 $((${#PHASE_NAMES[@]} - 1)) ); do
            phase_num=$(printf "%02d" $((i + 1)))
            phase_name=${PHASE_NAMES[$i]}
            PROGRESS_TABLE+="| $phase_num | [$phase_name] | | | Defined | | |\n"
        done

        cat > "$PROMPTS_DIR/project/PROGRESS.md" << EOF
# Phase Implementation Progress

This file tracks the implementation status of the project phases.

## Status Legend
- **Defined**: Phase prompt is complete but implementation has not started
- **In Progress**: Implementation has started but is not complete
- **Blocked**: Implementation cannot continue due to dependencies or issues
- **Testing**: Implementation is complete and undergoing testing/validation
- **Completed**: Phase is fully implemented and validated
- **Needs Review**: Implementation needs peer review

## Implementation Progress

| Phase ID | Component | Description | Key Dependencies | Status | Effort Est. | Notes |
|----------|-----------|-------------|------------------|--------|-------------|-------|
$PROGRESS_TABLE

## Implementation Order Rationale

[Add implementation order rationale here]

## Updating This File

[Add instructions for updating this file here]
EOF
    fi

    # Create PHASE_ASSESSMENT.md placeholder
    if [ ! -f "$PROMPTS_DIR/project/PHASE_ASSESSMENT.md" ]; then
        ASSESSMENT_TABLE=""
        for i in $(seq 0 $((${#PHASE_NAMES[@]} - 1)) ); do
            phase_name=${PHASE_NAMES[$i]}
            ASSESSMENT_TABLE+="| [$phase_name] | | | | |\n"
        done
        
        cat > "$PROMPTS_DIR/project/PHASE_ASSESSMENT.md" << 'EOF'
# Phase Readiness Assessment

This assessment evaluates each phase's clarity, dependencies, and measurability to determine readiness for implementation.

| Phase | Clarity of Goal | Key Tasks / Deliverables | Dependencies Clear? | Measurable "Done" Criteria |
|-------|----------------|--------------------------|---------------------|----------------------------|
$ASSESSMENT_TABLE

## Why This Looks Solid

[Add reasons why the phase plan looks solid]

## Areas for Attention

[Add areas that need attention or enhancement]
EOF
    fi
fi

echo "Done! Prompts directory structure created successfully."
echo "Next steps:"
echo "1. Update project management files with specific project details (if created)"
echo "2. Create phase-specific prompt files in the phases subdirectories"
echo "3. Add any necessary templates or guides to the appropriate directories"
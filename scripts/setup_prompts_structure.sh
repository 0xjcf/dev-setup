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
    echo "  --create-placeholders                  Create placeholder project management & phase files"
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
for i in $(seq 0 $((${#PHASE_NAMES[@]} - 1)) ); do
    phase=${PHASE_NAMES[$i]}
    # Sanitize phase name for directory creation (basic example)
    dir_name=$(echo "$phase" | sed 's/[^a-zA-Z0-9_-]/-/g')
    phase_path="$PROMPTS_DIR/phases/$dir_name"
    mkdir -p "$phase_path"
    echo "  Created: phases/$dir_name/"
    PHASE_DIRS_LIST+="│   ├── $dir_name/\n"

    # Create diagrams subdir in the first phase
    if [ $i -eq 0 ]; then
        mkdir -p "$phase_path/diagrams"
        echo "    Created: phases/$dir_name/diagrams/\n│   │   └── diagrams/     # Diagrams (architecture, state machines, etc.)\n"
        PHASE_DIRS_LIST+="         # Phase implementation & design\n│   │   └── diagrams/\n"
    else
        PHASE_DIRS_LIST+="      # Phase implementation\n"
    fi
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
- \`project/NEXT_PHASE.md\` - Guide for initiating subsequent phases/tasks.

### Implementation Phases

Each phase directory contains detailed prompts for implementing that phase. If created using \`--create-placeholders\`, common starting prompts may exist:
*   **Phase 01 (Planning/Design):** Typically includes design documents (\`01_domain_model.md\`, \`02_architecture_design.md\`) and diagrams (\`diagrams/\`).
*   **Phase 02 (Development):** Focuses on implementation prompts (\`01_<feature>_implementation.md\`), guided by Phase 01 designs.
*   **Phase 03 (Testing):** Contains testing definition prompts (\`01_test_plan.md\`, \`02_e2e_test_cases.md\`, \`03_accessibility_audit.md\`).

## Using These Prompts

1. Start with the project management files to understand the overall workflow.
2. Review the phase-specific prompts for planning and implementation details.
3. Use the templates and guides during development for consistent approaches.

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

    # Create NEXT_PHASE.md placeholder
    if [ ! -f "$PROMPTS_DIR/project/NEXT_PHASE.md" ]; then
        cat > "$PROMPTS_DIR/project/NEXT_PHASE.md" << 'EOF'
# Prompt: Initiate Next Phase/Task

## Objective
Review project status, confirm readiness for the next phase/task identified, ensure its prompt file is prepared with success criteria, and update progress tracking.

## Context Files
*   **Current Phase Prompt:** `{{CURRENT_PHASE_PROMPT_FILE}}` (e.g., `prompts/phases/01-planning/02_state_machine_refinement.md`)
*   **Previous Phase Prompt:** `{{PREVIOUS_PHASE_PROMPT_FILE}}` (e.g., `prompts/phases/01-planning/01_domain_model.md`)
*   **Progress Tracker:** `prompts/project/PROGRESS.md`
*   **Readiness Assessment:** `prompts/project/PHASE_ASSESSMENT.md`
*   **Prompts Overview:** `prompts/README.md`

## Review Steps
1.  **Check `PROGRESS.md`:**
    *   Verify `{{PREVIOUS_PHASE_PROMPT_FILE}}` component status is 'Completed'.
    *   Verify `{{CURRENT_PHASE_PROMPT_FILE}}` component status is 'Defined' or 'To Do'.
2.  **Check `PHASE_ASSESSMENT.md`:**
    *   Confirm the assessment for `{{CURRENT_PHASE_PROMPT_FILE}}` indicates readiness (Clarity, Dependencies Clear).
3.  **Review Prompts:**
    *   Read `{{CURRENT_PHASE_PROMPT_FILE}}`. Are the objectives and tasks clear?
    *   Briefly review outputs/content of `{{PREVIOUS_PHASE_PROMPT_FILE}}`. Is the handover logical?

## Preparation Steps
1.  **Define Success Criteria:** Based on the tasks in `{{CURRENT_PHASE_PROMPT_FILE}}`, formulate clear, measurable success criteria.
2.  **Update Current Prompt:** Edit `{{CURRENT_PHASE_PROMPT_FILE}}` to add a "## Success Criteria" section with the defined checklist.
3.  **Update Prompts README:** Edit `prompts/README.md` and add/update the entry for `{{CURRENT_PHASE_PROMPT_FILE}}` in the "Prompt Success Criteria" table.
4.  **Testing Alignment:** If the current work introduces new UI/API slices, ensure the related *Testing prompt(s)* (Phase 03) exist or are updated
    – e.g. add a unit/E2E test task row, update coverage gates, or create a new `03-testing/<feature>_tests.md`.
5.  **Deployment Impact:** If the current work affects build/runtime (new env-vars, Docker changes, infra settings), update or create the corresponding
    *Deployment prompt(s)* (Phase 04) and CI workflow notes (e.g. `04-deployment/ci_pipeline_updates.md`).

## Action
1.  **Confirm Readiness:** Are all review and preparation steps satisfactory?
2.  **Document Outcomes (Previous Task):** If applicable, add key decisions, takeaways, links to artifacts, or deviations to the 'Notes' column for the *previous* task (`{{PREVIOUS_PHASE_PROMPT_FILE}}`) in `PROGRESS.md`.
3.  **(If Ready) Update `PROGRESS.md`:** Change the status for the `{{CURRENT_PHASE_PROMPT_FILE}}` component to 'In Progress', adding a note like "Implementation starting: [First Task Name]".
4.  **(If Ready) Begin Task:** Proceed with the first task listed in `{{CURRENT_PHASE_PROMPT_FILE}}`. Follow this iterative development workflow:
    *   **a. Scaffold Component:** Create the basic file structure.
    *   **b. Implement Core UI/Logic:** Build the essential elements and functionality described in the task.
    *   **c. Unit/Integration Test Logic:** Write `vitest` tests for core logic, state, and interactions as they are built or immediately after.
    *   **d. Implement Routing/Guards:** Add necessary navigation logic (if applicable).
    *   **e. Integration Test Routing:** Verify navigation logic with `vitest` (if applicable).
    *   **f. E2E/Accessibility Tests:** Implement `playwright` tests and perform accessibility audits (`axe`/`Lighthouse`) once the component/feature is functional.
    *   **g. Review & Refine:** Check against prompt requirements and success criteria.
EOF
    fi

    # Create phase-specific placeholders
    echo "Creating placeholder phase files..."
    for i in $(seq 0 $((${#PHASE_NAMES[@]} - 1)) ); do
        phase=${PHASE_NAMES[$i]}
        dir_name=$(echo "$phase" | sed 's/[^a-zA-Z0-9_-]/-/g')
        phase_path="$PROMPTS_DIR/phases/$dir_name"

        # Heuristics based on common phase names/order
        if [ $i -eq 0 ] || [[ "$phase" == *"planning"* ]] || [[ "$phase" == *"design"* ]]; then
            echo "  Creating planning/design placeholders in: $phase_path"
            # 01_domain_model.md
            if [ ! -f "$phase_path/01_domain_model.md" ]; then
                echo "# Prompt: Define Domain Model\n\n## Objective\nDefine core data structures, interfaces, and relationships.\n\n## Tasks\n1. Identify entities.\n2. Define fields and types.\n3. Map relationships.\n4. Create diagram in diagrams/domain_model.mmd.\n\n## Success Criteria\n- [ ] Interfaces/types defined.\n- [ ] Relationships documented.\n- [ ] Diagram created." > "$phase_path/01_domain_model.md"
            fi
            # 02_architecture_design.md
            if [ ! -f "$phase_path/02_architecture_design.md" ]; then
                echo "# Prompt: Design System Architecture\n\n## Objective\nDefine the overall technical architecture (e.g., APIs, state management, data flow).\n\n## Tasks\n1. Choose architectural patterns.\n2. Define major components and interactions.\n3. Specify APIs / service contracts.\n4. Design state management approach.\n5. Create diagram in diagrams/architecture.mmd.\n\n## Success Criteria\n- [ ] Patterns selected.\n- [ ] Components defined.\n- [ ] APIs specified.\n- [ ] State management designed.\n- [ ] Diagram created." > "$phase_path/02_architecture_design.md"
            fi
        elif [[ "$phase" == *"development"* ]] || [[ "$phase" == *"implementation"* ]]; then
            echo "  Creating development README in: $phase_path"
            if [ ! -f "$phase_path/README.md" ]; then
                 echo "# Phase: $phase\n\nThis phase focuses on implementing the features and architecture designed in Phase $(printf "%02d" $i). \n\nPrompts in this directory (e.g., \`01_<feature>_implementation.md\`) will detail specific implementation tasks, referencing the relevant design documents from the previous phase." > "$phase_path/README.md"
            fi
        elif [[ "$phase" == *"testing"* ]]; then
            echo "  Creating testing placeholders in: $phase_path"
            # 01_test_plan.md
             if [ ! -f "$phase_path/01_test_plan.md" ]; then
                 echo "# Prompt: Define Test Plan\n\n## Objective\nOutline the strategy, scope, resources, and schedule for testing.\n\n## Sections\n- Scope (features in/out)\n- Test Levels (Unit, Integration, E2E, Accessibility)\n- Environments\n- Roles & Responsibilities\n- Tools\n- Schedule\n- Entry/Exit Criteria\n\n## Success Criteria\n- [ ] All sections completed." > "$phase_path/01_test_plan.md"
             fi
             # 02_e2e_test_cases.md
             if [ ! -f "$phase_path/02_e2e_test_cases.md" ]; then
                 echo "# Prompt: Define End-to-End (E2E) Test Cases\n\n## Objective\nDocument specific E2E test scenarios based on user flows.\n\n## Format (Example)\n| Test Case ID | User Flow         | Steps                                     | Expected Result        | Status |\n|--------------|-------------------|-------------------------------------------|------------------------|--------|\n| E2E-001      | Student Login     | 1. Navigate... 2. Enter... 3. Click... | User lands on dashboard | Pass   |\n\n## Success Criteria\n- [ ] Key user flows covered." > "$phase_path/02_e2e_test_cases.md"
             fi
             # 03_accessibility_audit.md
             if [ ! -f "$phase_path/03_accessibility_audit.md" ]; then
                 echo "# Prompt: Define Accessibility Audit Plan\n\n## Objective\nPlan the process for auditing WCAG compliance.\n\n## Sections\n- Scope (WCAG Level AA/AAA)\n- Tools (Axe, WAVE, Screen Readers)\n- Audit Process (Automated, Manual Keyboard, Manual Screen Reader)\n- Reporting Format\n\n## Success Criteria\n- [ ] Audit scope and process defined." > "$phase_path/03_accessibility_audit.md"
             fi
        fi
    done
fi

echo "Done! Prompts directory structure created successfully."
echo "Next steps:"
echo "1. Update project management files with specific project details (if created)"
echo "2. Refine placeholder phase prompts with project-specific details (if created)"
echo "3. Add any necessary templates or guides to the appropriate directories"
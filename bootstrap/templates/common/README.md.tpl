# Project Kickoff: [Project Name]

## 🎯 Overall Vision & Goal
*(High-level description of what this project aims to achieve. Similar to the intro of MVP_Kit/PROMPT.md)*

---

## 🧩 Core Components / Systems
*(List the major functional parts of the project. Analogous to listing client-intake, chatbot, agents, etc.)*

1.  **[Component 1 Name]:** (e.g., User Authentication Service) - Brief description of its role.
2.  **[Component 2 Name]:** (e.g., Data Processing Pipeline) - Brief description.
3.  **[Component 3 Name]:** (e.g., Web UI Dashboard) - Brief description.
4.  ...

---

## ⚙️ High-Level Workflow
*(Describe how the core components interact to fulfill the project's goal. Could be text or a Mermaid diagram like in MVP_Kit/PROMPT.md)*

```mermaid
graph TD
    A[Start] --> B(Component 1);
    B --> C{Decision};
    C -- Path 1 --> D[Component 2];
    C -- Path 2 --> E[Component 3];
    D --> F[End];
    E --> F;
```

---

## 🏗️ Required Scaffolds (from dev-setup)
*(List the types of standardized components that will need to be created using dev-setup bootstrap tasks. This references the *idea* from dev-setup prompts without including their full content.)*

-   **Type 1:** (e.g., `rust-api`) - Used for [Component 1 Name].
-   **Type 2:** (e.g., `node-cli`) - Used for [Component 2 Name].
-   **Type 3:** (e.g., `sveltekit-ui`) - Used for [Component 3 Name].
-   ...

---

## 🗓️ Phased Implementation Plan (Index)
*(This section acts as a table of contents for the detailed implementation steps. Each phase links conceptually to a separate prompt file using the hybrid format we developed for MVP_Kit prompts.)*

**Phase 1: [Phase 1 Goal]** (e.g., Setup Core Infrastructure)
   - *See: prompts/[component_dir]/01-[phase_name].md*
   - Key Outcomes: ...

**Phase 2: [Phase 2 Goal]** (e.g., Implement Auth Service Basics)
   - *See: prompts/[component_dir]/02-[phase_name].md*
   - Key Outcomes: ...

**Phase 3: [Phase 3 Goal]** (e.g., Build Initial UI Shell)
   - *See: prompts/[component_dir]/03-[phase_name].md*
   - Key Outcomes: ...

*(Continue listing all planned phases)*

---

## 🛠️ Key Technologies & Conventions
*(List standard tools and practices for this project, drawing from our established conventions.)*

-   **Package Manager:** pnpm
-   **Task Runner:** just (`justfile`)
-   **Linting/Formatting:** Biome (JS/TS), rustfmt/clippy (Rust)
-   **Testing:** Vitest/Playwright (JS/TS), cargo-nextest (Rust)
-   **Containerization:** Docker (using standard templates)
-   **Environment:** direnv (`.envrc`)
-   **Version Control:** Git, Conventional Commits
-   ...

---

## 🚀 Setup Instructions
*(Provide the specific commands needed to get this new project repository set up and bootstrapped.)*

1.  `git clone ...`
2.  `cd [Project Name]`
3.  `../dev-setup/setup.sh` (or project-specific setup)
4.  `./bootstrap.sh` (or `just bootstrap-all`)
5.  `direnv allow`
#!/bin/bash

# Project Class Selection
select_project_class() {
  echo "Selecting project class..."
  # Logic for selecting project class
  if [[ -n "$CLASS" ]]; then
    echo "Project class selected: $CLASS"
  else
    echo "No project class selected. Prompting user..."
    # Prompt user for project class
  fi
}

# select_project_class # REMOVED CALL 
# Template Development Tasks
template-process:
    #!/usr/bin/env bash
    echo "Processing templates with format validation..."
    ./template-process.sh "$(pwd)/templates/node/api" "$(pwd)/bootstrap-test/node/test-api" "project_name port"
    ./template-process.sh "$(pwd)/templates/node/ui/common" "$(pwd)/bootstrap-test/node/test-ui" "project_name" 
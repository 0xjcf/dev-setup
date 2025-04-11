# 📦 Task: Modularize Bootstrap Scaffolds

## 🎯 Objective
Move all hardcoded scaffolding logic from `bootstrap.sh` into structured template files.

## 📋 Requirements

### 1. Directory Structure
```
templates/
├── node/
│   ├── api/
│   │   ├── package.json.tpl
│   │   ├── src/index.ts.tpl
│   │   ├── test/index.test.ts.tpl
│   │   └── README.md.tpl
│   ├── ui/
│   │   ├── package.json.tpl
│   │   ├── src/main.tsx.tpl
│   │   ├── test/main.test.tsx.tpl
│   │   └── README.md.tpl
│   ├── lib/
│   │   └── ...
│   └── cli/
│       └── ...
├── rust/
│   ├── api/
│   │   ├── Cargo.toml.tpl
│   │   ├── src/main.rs.tpl
│   │   ├── test/health_check.rs.tpl
│   │   └── README.md.tpl
│   ├── agent/
│   │   └── ...
│   ├── lib/
│   │   └── ...
│   └── cli/
│       └── ...
└── go/
    ├── api/
    │   └── ...
    ├── lib/
    │   └── ...
    └── cli/
        └── ...
```

### 2. Template Variables
Common variables to be replaced:
- `{{project_name}}`: Name of the project
- `{{entry_point}}`: Main entry file
- `{{port}}`: Port number for services
- `{{version}}`: Project version
- `{{description}}`: Project description
- `{{author}}`: Project author
- `{{license}}`: Project license

### 3. Template Format
```json
{
  "metadata": {
    "tech": "node",
    "class": "api",
    "version": "1.0.0",
    "variables": ["project_name", "port", "version"]
  },
  "files": [
    {
      "path": "package.json",
      "template": "templates/node/api/package.json.tpl",
      "variables": ["project_name", "version"]
    },
    {
      "path": "src/index.ts",
      "template": "templates/node/api/src/index.ts.tpl",
      "variables": ["port"]
    }
  ]
}
```

### 4. Implementation Steps

1. **Extract Templates**
   ```bash
   # Create template directories
   mkdir -p templates/{node,rust,go}/{api,ui,lib,cli}
   
   # Extract Node.js API templates
   cp bootstrap.sh templates/node/api/package.json.tpl
   cp bootstrap.sh templates/node/api/src/index.ts.tpl
   # ... repeat for other files
   ```

2. **Update Template Files**
   - Replace hardcoded values with variables
   - Add metadata headers
   - Document variable usage

3. **Update Bootstrap Script**
   ```bash
   # Add template loading function
   load_template() {
     local tech=$1
     local class=$2
     local file=$3
     local template="templates/$tech/$class/$file.tpl"
     
     if [ -f "$template" ]; then
       envsubst < "$template"
     else
       echo "Template not found: $template"
       return 1
     fi
   }
   ```

4. **Add Template Validation**
   - Check for required variables
   - Validate template syntax
   - Test template rendering

### 5. Success Criteria

1. **Functionality**
   - [ ] All templates are extracted
   - [ ] Variables are properly replaced
   - [ ] Bootstrap script works with templates
   - [ ] Dry run shows correct output

2. **Quality**
   - [ ] Templates are well-documented
   - [ ] Variables are clearly defined
   - [ ] Error handling is robust
   - [ ] Templates are versioned

3. **Maintenance**
   - [ ] Templates are easy to update
   - [ ] New templates can be added
   - [ ] Variables can be extended
   - [ ] Version control friendly

### 6. Testing

1. **Template Testing**
   ```bash
   # Test template loading
   load_template node api package.json
   
   # Test variable replacement
   PROJECT_NAME=test PORT=3000 load_template node api src/index.ts
   
   # Test dry run
   ./bootstrap.sh --dry-run --config=test.json
   ```

2. **Integration Testing**
   - Create test projects
   - Verify template rendering
   - Check file permissions
   - Validate generated files

### 7. Notes

- Use consistent variable naming
- Document all templates
- Keep templates minimal
- Support template inheritance
- Consider template composition
- Add template validation
- Support template overrides 
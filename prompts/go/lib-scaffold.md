# 📦 Go Library Scaffolding

## 🎯 Objective
Create a reusable Go library scaffold that follows best practices and includes all necessary tooling for development, testing, and publishing.

## 📋 Requirements

### 1. Directory Structure
```
lib/
├── lib.go              # Main library code
├── lib_test.go         # Tests
├── utils.go            # Utility functions
├── utils_test.go       # Utility tests
├── examples/           # Example usage
│   └── basic.go
├── go.mod              # Go module definition
├── go.sum              # Dependency checksums
├── .golangci.yml       # GolangCI-Lint configuration
└── README.md           # Documentation
```

### 2. Go Module Configuration
```go
// go.mod
module github.com/yourusername/lib-name

go 1.21

require (
    github.com/stretchr/testify v1.8.4
)

require (
    github.com/davecgh/go-spew v1.1.1 // indirect
    github.com/pmezard/go-difflib v1.0.0 // indirect
    gopkg.in/yaml.v3 v3.0.1 // indirect
)
```

### 3. Dependencies
- Runtime:
  - None (standard library)
- Dev:
  - `github.com/stretchr/testify` (for testing)
  - `golangci-lint` (for linting)

### 4. Example Implementation
```go
// lib.go
package lib

import (
    "errors"
    "fmt"
)

// ErrInvalidInput is returned when input validation fails
var ErrInvalidInput = errors.New("invalid input")

// Add adds two integers and returns the result
func Add(a, b int) int {
    return a + b
}

// Greet returns a greeting for the given name
func Greet(name string) (string, error) {
    if name == "" {
        return "", fmt.Errorf("%w: name cannot be empty", ErrInvalidInput)
    }
    return fmt.Sprintf("Hello, %s!", name), nil
}
```

### 5. Test Implementation
```go
// lib_test.go
package lib

import (
    "testing"

    "github.com/stretchr/testify/assert"
)

func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, -1, -2},
        {"zero", 0, 0, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            assert.Equal(t, tt.expected, Add(tt.a, tt.b))
        })
    }
}

func TestGreet(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
        wantErr  bool
    }{
        {"valid name", "World", "Hello, World!", false},
        {"empty name", "", "", true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Greet(tt.input)
            if tt.wantErr {
                assert.Error(t, err)
                assert.ErrorIs(t, err, ErrInvalidInput)
            } else {
                assert.NoError(t, err)
                assert.Equal(t, tt.expected, got)
            }
        })
    }
}
```

## 🔧 Implementation Steps

1. **Setup Project Structure**
   ```bash
   mkdir -p lib/examples
   cd lib
   ```

2. **Initialize Go Module**
   ```bash
   go mod init github.com/yourusername/lib-name
   ```

3. **Install Dependencies**
   ```bash
   go get github.com/stretchr/testify
   go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
   ```

4. **Create Configuration Files**
   - `.golangci.yml` with linting rules
   - Update `go.mod` with dependencies

5. **Implement Core Files**
   - Create library code with example functions
   - Add test files
   - Add example usage
   - Add README with usage examples

6. **Add Documentation**
   - Add doc comments
   - Add examples
   - Add README with usage examples

## ✅ Success Criteria

1. **Functionality**
   - [ ] Library can be imported and used
   - [ ] All tests pass
   - [ ] Examples work
   - [ ] Linting passes

2. **Quality**
   - [ ] Code is properly formatted
   - [ ] Linting passes
   - [ ] Documentation is complete
   - [ ] Examples are provided

3. **Documentation**
   - [ ] README is complete
   - [ ] API is documented
   - [ ] Examples are provided
   - [ ] Contributing guidelines are included

4. **Tooling**
   - [ ] All go commands work
   - [ ] Linting is configured
   - [ ] Tests are configured

## 🔍 Testing

1. **Manual Testing**
   ```bash
   # Format
   go fmt ./...
   
   # Lint
   golangci-lint run
   
   # Test
   go test ./...
   
   # Test with coverage
   go test -cover ./...
   
   # Test with race detector
   go test -race ./...
   ```

2. **Integration Testing**
   - Create a test project
   - Import and use the library
   - Verify functionality

## 📝 Notes

- Follow Go best practices
- Use proper error handling
- Document all public APIs
- Include examples
- Use table-driven tests
- Follow semantic versioning
- Use proper package organization 
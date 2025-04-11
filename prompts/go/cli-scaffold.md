# 📦 Go CLI Scaffolding

## 🎯 Objective
Create a reusable Go CLI scaffold using Cobra that follows best practices and includes all necessary tooling for development, testing, and distribution.

## 📋 Requirements

### 1. Directory Structure
```
cli/
├── cmd/
│   ├── root.go         # Root command
│   ├── run.go          # Run command
│   └── config.go       # Config command
├── internal/
│   ├── cmd/            # Command implementations
│   │   ├── run.go
│   │   └── config.go
│   └── utils/          # Shared utilities
├── pkg/
│   └── lib/            # Reusable library code
├── main.go             # CLI entry point
├── go.mod              # Go module definition
├── go.sum              # Dependency checksums
├── .golangci.yml       # GolangCI-Lint configuration
└── README.md           # Documentation
```

### 2. Go Module Configuration
```go
// go.mod
module github.com/yourusername/cli-name

go 1.21

require (
	github.com/spf13/cobra v1.8.0
	github.com/spf13/viper v1.18.2
)

require (
	github.com/fsnotify/fsnotify v1.7.0 // indirect
	github.com/hashicorp/hcl v1.0.0 // indirect
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/magiconair/properties v1.8.7 // indirect
	github.com/mitchellh/mapstructure v1.5.0 // indirect
	github.com/pelletier/go-toml/v2 v2.1.0 // indirect
	github.com/sagikazarmark/locafero v0.4.0 // indirect
	github.com/sagikazarmark/slog-shim v0.1.0 // indirect
	github.com/sourcegraph/conc v0.3.0 // indirect
	github.com/spf13/afero v1.11.0 // indirect
	github.com/spf13/cast v1.6.0 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	github.com/subosito/gotenv v1.6.0 // indirect
	go.uber.org/atomic v1.9.0 // indirect
	go.uber.org/multierr v1.9.0 // indirect
	golang.org/x/exp v0.0.0-20230905200255-921286631fa9 // indirect
	golang.org/x/sys v0.15.0 // indirect
	golang.org/x/text v0.14.0 // indirect
	gopkg.in/ini.v1 v1.67.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
```

### 3. Dependencies
- Runtime:
  - `github.com/spf13/cobra` (for CLI parsing)
  - `github.com/spf13/viper` (for configuration)
- Dev:
  - `github.com/stretchr/testify` (for testing)
  - `golangci-lint` (for linting)

### 4. Example Implementation
```go
// cmd/root.go
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var rootCmd = &cobra.Command{
	Use:   "mycli",
	Short: "A CLI tool for doing things",
	Long: `A longer description that spans multiple lines and likely contains
examples and usage of using your command.`,
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)
}

func initConfig() {
	viper.AutomaticEnv()
}
```

```go
// cmd/run.go
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var runCmd = &cobra.Command{
	Use:   "run",
	Short: "Run the main task",
	Long:  `Run the main task with optional force flag.`,
	Run: func(cmd *cobra.Command, args []string) {
		force, _ := cmd.Flags().GetBool("force")
		if force {
			fmt.Println("Running with force...")
		} else {
			fmt.Println("Running...")
		}
	},
}

func init() {
	rootCmd.AddCommand(runCmd)
	runCmd.Flags().BoolP("force", "f", false, "Force execution")
}
```

### 5. Test Implementation
```go
// cmd/root_test.go
package cmd

import (
	"bytes"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRootCommand(t *testing.T) {
	cmd := rootCmd
	b := bytes.NewBufferString("")
	cmd.SetOut(b)
	cmd.SetArgs([]string{"--help"})
	err := cmd.Execute()
	assert.NoError(t, err)
	assert.Contains(t, b.String(), "A CLI tool for doing things")
}

func TestRunCommand(t *testing.T) {
	cmd := runCmd
	b := bytes.NewBufferString("")
	cmd.SetOut(b)
	cmd.SetArgs([]string{"--force"})
	err := cmd.Execute()
	assert.NoError(t, err)
	assert.Contains(t, b.String(), "Running with force...")
}
```

## 🔧 Implementation Steps

1. **Setup Project Structure**
   ```bash
   mkdir -p cli/{cmd,internal/{cmd,utils},pkg/lib}
   cd cli
   ```

2. **Initialize Go Module**
   ```bash
   go mod init github.com/yourusername/cli-name
   ```

3. **Install Dependencies**
   ```bash
   go get github.com/spf13/cobra
   go get github.com/spf13/viper
   go get github.com/stretchr/testify
   go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
   ```

4. **Create Configuration Files**
   - `.golangci.yml` with linting rules
   - Update `go.mod` with dependencies

5. **Implement Core Files**
   - Create CLI entry point with Cobra setup
   - Add command implementations
   - Add test files
   - Add README with usage examples

6. **Add Documentation**
   - Add doc comments
   - Add examples
   - Add README with usage examples

## ✅ Success Criteria

1. **Functionality**
   - [ ] CLI can be installed
   - [ ] Commands work as expected
   - [ ] Help text is properly formatted
   - [ ] Tests pass
   - [ ] Linting passes

2. **Quality**
   - [ ] Code is properly formatted
   - [ ] Linting passes
   - [ ] Documentation is complete
   - [ ] Examples are provided

3. **Documentation**
   - [ ] README is complete
   - [ ] All commands are documented
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
   
   # Build
   go build
   
   # Run
   ./cli-name --help
   ```

2. **Integration Testing**
   - Install the CLI
   - Test all commands
   - Verify help text
   - Check error handling

## 📝 Notes

- Use Cobra for CLI parsing
- Follow CLI best practices
- Provide clear error messages
- Include examples in help text
- Use proper error handling
- Support configuration via Viper
- Follow Go project layout conventions
- Use proper package organization 
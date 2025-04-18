{
	"$schema": "https://biomejs.dev/schemas/1.9.4/schema.json",
	"organizeImports": {
		"enabled": true
	},
	"files": {
		"ignore": [
			"**/node_modules/**",
			"**/dist/**",
			"**/build/**",
			"**/.next/**",
			"**/out/**",
			"**/coverage/**",
			"**/*.lock",
			"**/package-lock.json",
			"**/pnpm-lock.yaml",
			"**/yarn.lock",
			"tsconfig.json",
			"tsconfig.node.json",
			"tsconfig.*.json"
		]
	},
	"linter": {
		"enabled": true,
		"rules": {
			"recommended": true
		}
	},
	"formatter": {
		"enabled": true,
		"indentStyle": "tab",
		"lineWidth": 100
	},
	"javascript": {
		"formatter": {
			"quoteStyle": "double",
			"trailingCommas": "es5",
			"semicolons": "always"
		}
	}
}

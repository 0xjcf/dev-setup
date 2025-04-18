{
	"name": "${project_name}",
	"version": "${version}",
	"description": "${description}",
	"type": "module",
	"main": "dist/${entry_point}.js",
	"scripts": {
		"dev": "tsx watch src/${entry_point}.ts",
		"build": "tsc",
		"start": "node dist/${entry_point}.js",
		"test": "NODE_ENV=test tsx --test test/*.test.ts",
		"test:watch": "NODE_ENV=test tsx --test --watch test/*.test.ts",
		"lint": "biome check .",
		"format": "biome format . --write",
		"lint:fix": "biome check . --write"
	},
	"dependencies": {
		"express": "latest",
		"@types/express": "latest",
		"dotenv": "latest",
		"typescript": "latest",
		"tsx": "latest"
	},
	"devDependencies": {
		"@biomejs/biome": "latest",
		"@types/node": "latest",
		"supertest": "latest",
		"@types/supertest": "latest"
	},
	"packageManager": "pnpm@8.15.4"
}

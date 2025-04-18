#!/bin/bash

# ------------------------------------------------------
# Node.js API Project Setup
# ------------------------------------------------------

setup_node_api() {
  local dir="$1"
  local project_name=$(basename "$dir")
  
  section "Setting up Node.js API project: $project_name"
  
  # Initialize project
  start_progress "Initializing project"
  pnpm init
  end_progress $?
  
  # Install dependencies
  start_progress "Installing core dependencies"
  pnpm add express @types/express typescript tsx dotenv
  end_progress $?
  
  start_progress "Installing development dependencies"
  pnpm add -D vitest @types/node @biomejs/biome supertest @types/supertest
  end_progress $?
  
  # Initialize TypeScript
  start_progress "Setting up TypeScript"
  pnpm tsc --init
  end_progress $?
  
  # Initialize Biome
  start_progress "Setting up Biome"
  pnpm exec biome init
  end_progress $?
  
  # Create project structure
  start_progress "Creating project structure"
  mkdir -p src/{routes,controllers,services,types}
  end_progress $?
  
  # Create project files
  section "Creating project files"
  
  # Create main application file
  cat > src/index.ts << 'EOL'
import { config } from 'dotenv';
import express from 'express';

config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'API is running!' });
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
}

export { app };
EOL

  # Create test file
  mkdir -p test
  cat > test/index.test.ts << 'EOL'
import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { app } from '../src/index';

describe('API Tests', () => {
  it('should respond with welcome message on root endpoint', async () => {
    const response = await request(app)
      .get('/')
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toEqual({ message: 'API is running!' });
  });
});
EOL

  # Create environment file
  cat > .env << 'EOL'
PORT=3000
NODE_ENV=development
EOL

  # Create gitignore
  cat > .gitignore << 'EOL'
node_modules/
dist/
coverage/
.env
.DS_Store
EOL

  # Update package.json scripts
  start_progress "Updating package.json scripts"
  pnpm pkg set scripts.start="tsx src/index.ts"
  pnpm pkg set scripts.dev="tsx watch src/index.ts"
  pnpm pkg set scripts.build="tsc"
  pnpm pkg set scripts.test="NODE_ENV=test vitest run"
  pnpm pkg set scripts.test:watch="NODE_ENV=test vitest"
  pnpm pkg set scripts.lint="biome check ."
  pnpm pkg set scripts.format="biome format --write ."
  end_progress $?

  # Format the project
  start_progress "Formatting project"
  pnpm exec biome format --write .
  end_progress $?

  section "Project setup complete!"
  info "✅ Node.js API project bootstrapped successfully"
  
  # Print next steps
  cat << EOF

🎉 Next steps:
  1. cd ${project_name}
  2. pnpm dev     - Start development server
  3. pnpm test    - Run tests
  4. pnpm lint    - Check code quality
  
📚 Project structure:
  src/
    ├── routes/      - API route handlers
    ├── controllers/ - Business logic
    ├── services/    - External service integrations
    └── types/       - TypeScript type definitions
  
  test/             - Test files
  
EOF
} 
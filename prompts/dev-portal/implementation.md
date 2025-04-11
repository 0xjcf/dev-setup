# 🧪 Task: Build Visual Dev Portal for Bootstrapper

## 🎯 Objective
Develop a React-based Dev Portal that allows users to visually configure and generate monorepo projects using `bootstrap.sh`.

## 📋 Requirements

### 1. Directory Structure
```
dev-portal/
├── src/
│   ├── components/
│   │   ├── StackExplorer/
│   │   │   ├── StackCard.tsx
│   │   │   └── ProjectTypeCard.tsx
│   │   ├── ProjectBuilder/
│   │   │   ├── ProjectForm.tsx
│   │   │   └── ProjectList.tsx
│   │   ├── Preview/
│   │   │   ├── FileTree.tsx
│   │   │   └── FilePreview.tsx
│   │   └── BootstrapRunner/
│   │       └── Runner.tsx
│   ├── pages/
│   │   ├── Home.tsx
│   │   ├── Builder.tsx
│   │   └── Preview.tsx
│   ├── utils/
│   │   ├── templates.ts
│   │   ├── config.ts
│   │   └── bootstrap.ts
│   └── types/
│       └── index.ts
├── public/
│   └── templates/          # Client-side templates
├── vite.config.ts
└── package.json
```

### 2. Core Features

1. **Stack Explorer**
   ```typescript
   interface TechStack {
     id: string;
     name: string;
     icon: string;
     description: string;
     projectTypes: ProjectType[];
   }

   interface ProjectType {
     id: string;
     name: string;
     description: string;
     template: string;
   }
   ```

2. **Project Config Builder**
   ```typescript
   interface ProjectConfig {
     path: string;
     type: string;
     class: string;
     options: {
       port?: number;
       version?: string;
       description?: string;
     };
   }
   ```

3. **Preview Generator**
   ```typescript
   interface FilePreview {
     path: string;
     content: string;
     language: string;
   }
   ```

### 3. Implementation Steps

1. **Setup Project**
   ```bash
   # Create React project
   pnpm create vite dev-portal --template react-ts
   cd dev-portal
   
   # Install dependencies
   pnpm add @headlessui/react @heroicons/react react-json-view react-treebeard
   pnpm add -D @types/react-json-view tailwindcss postcss autoprefixer
   ```

2. **Create Components**
   - Stack Explorer
   - Project Builder
   - Preview Generator
   - Bootstrap Runner

3. **Add Templates**
   - Load templates from filesystem
   - Support template preview
   - Handle template variables

4. **Implement Bootstrap Integration**
   - Generate monorepo.json
   - Run bootstrap.sh
   - Handle output/errors

### 4. Success Criteria

1. **Functionality**
   - [ ] Stack explorer works
   - [ ] Project builder works
   - [ ] Preview generator works
   - [ ] Bootstrap runner works

2. **Quality**
   - [ ] UI is responsive
   - [ ] Code is well-typed
   - [ ] Error handling is robust
   - [ ] Performance is good

3. **User Experience**
   - [ ] Intuitive interface
   - [ ] Clear feedback
   - [ ] Helpful tooltips
   - [ ] Smooth transitions

### 5. Testing

1. **Component Testing**
   ```typescript
   // StackExplorer.test.tsx
   describe('StackExplorer', () => {
     it('renders tech stacks', () => {
       // Test implementation
     });
   });
   ```

2. **Integration Testing**
   - Test project creation
   - Test template preview
   - Test bootstrap execution
   - Test error handling

### 6. Notes

- Use TypeScript for type safety
- Follow React best practices
- Use Tailwind for styling
- Add proper error boundaries
- Implement loading states
- Add keyboard navigation
- Support dark mode
- Add accessibility features 
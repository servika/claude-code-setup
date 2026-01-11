# Claude Code Agents

Specialized agents for enhanced development assistance across different aspects of your JavaScript/Node.js/React project.

## Available Agents

### 1. Project Interview Agent ⭐ NEW!
**File**: `project-interview.md`

**🎯 START HERE!** Conducts a comprehensive interview to configure the project for your specific needs.

**Use Cases**:
- Setting up new projects with this configuration
- Onboarding configuration to existing projects
- Gathering team preferences and technical requirements
- Creating project-specific configuration profile
- Generating starter config files

**How to Invoke**:
```
Claude, use the project interview agent to configure this project
```

**Example**:
```
Claude, I'm starting a new e-commerce project. Use the project interview agent to set it up.
```

**What it creates**:
- `.claude/project-config.json` - Your project profile
- `.env.example` - Environment variables template
- ESLint/Prettier configs
- Test configuration
- Docker setup (if needed)
- CI/CD workflow files

---

### 2. Library Analyzer Agent
**File**: `library-analyzer.md`

Analyzes open source libraries for security, compatibility, and best alternatives.

**Use Cases**:
- Evaluating new dependencies before installation
- Security audits of existing dependencies
- Finding better alternatives to current libraries
- Investigating npm security warnings
- Planning dependency upgrades

**How to Invoke**:
```
Claude, use the library analyzer agent to evaluate [package-name]
```

**Example**:
```
Claude, analyze axios vs native fetch for our API calls using the library analyzer agent
```

---

### 3. Backend Code Generator Agent
**File**: `backend-generator.md`

Generates production-ready Node.js/Express backend code following best practices.

**Use Cases**:
- Creating new API endpoints
- Building Express routes, controllers, services
- Implementing middleware
- Setting up authentication/authorization
- Creating database models and queries
- Implementing error handling

**How to Invoke**:
```
Claude, use the backend generator agent to create [feature]
```

**Example**:
```
Claude, use the backend generator agent to create a user management API with CRUD operations
```

---

### 4. Frontend Code Generator Agent
**File**: `frontend-generator.md`

Generates production-ready React components with Material-UI following best practices.

**Use Cases**:
- Creating new React components
- Building forms with MUI
- Implementing data tables/lists
- Creating layouts and navigation
- Building authentication UI
- Creating custom hooks

**How to Invoke**:
```
Claude, use the frontend generator agent to create [component]
```

**Example**:
```
Claude, use the frontend generator agent to create a user profile form with validation
```

---

### 5. Project Documentation Generator Agent
**File**: `project-docs-generator.md`

Generates comprehensive project-level documentation.

**Use Cases**:
- Creating initial project documentation
- Updating README after major changes
- Generating user guides
- Creating deployment documentation
- Documenting project setup and configuration
- Writing contributing guidelines

**How to Invoke**:
```
Claude, use the project docs generator agent to create [document]
```

**Example**:
```
Claude, use the project docs generator agent to create a comprehensive README
```

---

### 6. Development Documentation Generator Agent
**File**: `dev-docs-generator.md`

Generates technical development documentation.

**Use Cases**:
- Creating development guidelines
- Documenting coding standards
- Writing testing documentation
- Creating debugging guides
- Documenting CI/CD processes
- Writing contribution guidelines

**How to Invoke**:
```
Claude, use the dev docs generator agent to create [document]
```

**Example**:
```
Claude, use the dev docs generator agent to create a testing guide
```

---

### 7. Architecture Documentation Generator Agent
**File**: `architecture-docs-generator.md`

Generates comprehensive architecture documentation.

**Use Cases**:
- Creating initial architecture documentation
- Documenting major architectural decisions
- Creating system design diagrams
- Documenting database schemas
- Writing API architecture docs
- Creating component architecture documentation

**How to Invoke**:
```
Claude, use the architecture docs generator agent to document [aspect]
```

**Example**:
```
Claude, use the architecture docs generator agent to create a system architecture document
```

---

## How Agents Work

Each agent is a specialized instruction set that guides Claude Code to:

1. **Analyze** - Understand the specific context and requirements
2. **Apply Best Practices** - Follow established patterns for that domain
3. **Generate** - Create high-quality, production-ready output
4. **Validate** - Ensure completeness and correctness

## When to Use Agents

### Use Library Analyzer Agent When:
- Adding new npm packages
- Security audit shows vulnerabilities
- Bundle size is too large
- Looking for alternatives to existing dependencies
- Planning major dependency upgrades

### Use Backend Generator Agent When:
- Creating new API endpoints
- Need full CRUD operations
- Implementing authentication/authorization
- Building new services or controllers
- Need middleware implementation

### Use Frontend Generator Agent When:
- Creating new React components
- Building forms with complex validation
- Implementing data tables or lists
- Creating reusable UI components
- Need custom hooks for data fetching

### Use Project Docs Generator Agent When:
- Starting a new project
- Onboarding new team members
- Major features added that need documentation
- Deployment process changes
- README is outdated

### Use Dev Docs Generator Agent When:
- Team coding standards need documentation
- Testing practices need to be formalized
- New developers need debugging guides
- Contributing guidelines missing
- Development workflow changes

### Use Architecture Docs Generator Agent When:
- Starting a new project (initial architecture)
- Making major architectural changes
- Need to document technical decisions
- Onboarding architects or senior developers
- Planning scalability improvements

## Agent Invocation Patterns

### Single Agent Task
```
Claude, use the [agent-name] agent to [specific task]
```

### Multi-Step with Agent
```
Claude, use the backend generator agent to:
1. Create user authentication API
2. Add password reset functionality
3. Implement email verification
```

### Sequential Agent Use
```
Claude, first use the library analyzer agent to evaluate authentication libraries,
then use the backend generator agent to implement the recommended solution
```

### Combined Approach
```
Claude, use the frontend generator agent to create the login form,
then use the backend generator agent to create the authentication API,
finally use the project docs generator agent to document the authentication flow
```

## Best Practices

### ✅ Do

- **Be specific**: Provide clear requirements when invoking agents
- **Provide context**: Mention existing code/patterns that should be followed
- **Review output**: Always review generated code/documentation
- **Iterate**: Ask agent to refine if needed
- **Combine agents**: Use multiple agents for complex features

### ❌ Don't

- **Vague requests**: "Make it better" - be specific about what you want
- **Skip review**: Always review generated code for your specific use case
- **Ignore warnings**: Pay attention to security/performance warnings
- **Over-rely**: Agents are helpers, not replacements for understanding

## Examples

### Example 1: New Feature Development

```
User: I need to add user profile management

Claude: Let me help you build this feature using specialized agents.

First, let me use the backend generator agent to create the API:
[Creates routes, controllers, services with full CRUD]

Now, let me use the frontend generator agent to create the UI:
[Creates profile form, profile view, edit functionality]

Finally, let me use the project docs generator agent to document this:
[Updates API docs, adds usage examples]
```

### Example 2: Dependency Evaluation

```
User: Should we use Moment.js or date-fns?

Claude: Let me use the library analyzer agent to evaluate both options.

[Provides detailed comparison]:
- Security analysis
- Bundle size comparison
- Maintenance status
- Performance benchmarks
- Recommendation with rationale
```

### Example 3: Architecture Documentation

```
User: We need to document our system architecture for new team members

Claude: I'll use the architecture docs generator agent to create comprehensive documentation.

[Generates]:
- System architecture diagram
- Data flow documentation
- Technology stack overview
- Deployment architecture
- Security architecture
- Scalability considerations
```

## Customizing Agents

You can customize agents by:

1. **Editing agent files**: Modify `.claude/agents/*.md` files
2. **Adding new sections**: Extend templates for your specific needs
3. **Creating new agents**: Copy existing agent structure for new domains
4. **Adjusting standards**: Update coding standards to match your team

### Creating a New Agent

```markdown
# [Agent Name] Agent

## Purpose
[What this agent does]

## When to Invoke
[Specific use cases]

## Generation Principles
[Core principles and standards]

## Generation Templates
[Code/documentation templates]

## Best Practices
[Do's and don'ts]
```

## Integration with Git Hooks

Agents work seamlessly with git hooks:

- **Pre-commit**: Auto-generates documentation from JSDoc
- **Code review**: Use agents to verify best practices
- **CI/CD**: Can be integrated into automated checks

## Troubleshooting

### Agent Not Following Instructions

**Solution**: Be more specific in your request. Provide examples or reference existing code patterns.

### Generated Code Doesn't Match Project Style

**Solution**: Reference existing files as examples or customize the agent file to match your standards.

### Agent Missing Context

**Solution**: Provide file paths, existing implementations, or architectural constraints in your request.

## Contributing

To improve agents:

1. Identify gaps or improvements needed
2. Edit relevant agent file in `.claude/agents/`
3. Test with real scenarios
4. Update this README if adding new agents
5. Commit changes with descriptive message

## Support

For issues or questions:
- Review agent documentation in `.claude/agents/`
- Check examples in this README
- Consult main project documentation in `/docs`

---

**Happy coding with specialized agents!** 🚀

Use agents to boost productivity while maintaining code quality and consistency across your project.
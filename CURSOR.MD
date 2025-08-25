# Git Flow Boilerplate Project

## Project Identity
```markdown
# Universal Git Flow Boilerplate
## What this project does (1-2 sentences)
A comprehensive boilerplate git flow system that provides standardized project templates, automated documentation generation, GitHub Pages integration, and multi-language support for all modern development workflows.

## Tech stack / Framework
Multi-language support: Rust, Python, Bash, PHP, Node.js, JavaScript, React, Vue.js
Documentation: GitHub Pages, docs.github, Mermaid diagrams, automated API docs
CI/CD: GitHub Actions, automated testing, deployment workflows
Tools: Git Flow, automated documentation generation, project templates
```

## File Structure Guide
```markdown
## Key Files & Directories
- `.github/` - GitHub Actions workflows, issue templates, and GitHub-specific configurations
- `docs/` - Documentation source files, GitHub Pages content, and API documentation
- `examples/` - Multi-language hello world examples and boilerplate code
- `templates/` - Project templates for different languages and frameworks
- `scripts/` - Automation scripts for documentation generation and project setup
- `workflows/` - Git flow automation and CI/CD pipeline configurations
- `.claude/` - AI assistant instructions and task management system

## Entry Points
- Main setup: `./setup.sh` - Initialize new project with selected language/framework
- Documentation: `./scripts/generate-docs.sh` - Generate all documentation
- Tests: `./scripts/run-tests.sh` - Run tests across all language examples
- Build: `./scripts/build-all.sh` - Build all examples and documentation
```

## How to Work With This Project
```markdown
## Development Workflow
- **Local setup**: [Steps to get running locally]
- **Testing**: [How to run tests - unit, integration, e2e]
- **Building**: [Build commands and process]
- **Deployment**: [How deployment works]

## Common Tasks
- **Add new feature**: 
  - Edit files: [list key files to modify]
  - Follow pattern: [describe the pattern]
  - Test by: [how to verify it works]
  
- **Fix bug**: 
  - Check files: [where to look first]
  - Common issues: [typical problems and solutions]
  
- **Update configuration**: 
  - Modify: [which config files]
  - Restart: [what needs restarting]
  - Verify: [how to check it worked]
```

## Code Patterns & Conventions
```markdown
## Code Structure
- **Naming conventions**: [camelCase, snake_case, PascalCase usage]
- **File organization**: [where different types of files go]
- **Import/export patterns**: [how modules are structured]
- **State management**: [Redux, Context, Vuex, etc.]
- **API integration**: [where API calls go, how they're structured]

## Important Patterns
- **Error handling**: [standard error handling approach]
- **Logging**: [logging library and conventions]
- **Authentication**: [how auth is handled]
- **Data validation**: [validation patterns and libraries]
- **Testing patterns**: [testing conventions and helpers]

## Architecture Notes
- **Database**: [ORM, migrations, key tables]
- **API design**: [REST, GraphQL, endpoints structure]
- **Frontend structure**: [components, pages, routing]
- **Background jobs**: [queue system, scheduled tasks]
```

## Context & Constraints
```markdown
## What NOT to touch
- [Files/directories that should not be modified]
- [Legacy code that needs special handling]
- [External dependencies with specific versions]
- [Configuration that requires approval]

## Environment & Secrets
- **Environment variables**: [key env vars and their purpose]
- **API keys**: [where they're stored, how to access]
- **Database connections**: [how connections are configured]
- **External services**: [third-party integrations]

## Current Focus
- [What the team is currently working on]
- [Known issues or technical debt]
- [Upcoming changes or refactoring plans]
- [Performance considerations]

## Dependencies & Requirements
- **Runtime requirements**: [Node version, Python version, etc.]
- **Key dependencies**: [critical packages and their versions]
- **Development tools**: [linters, formatters, pre-commit hooks]
- **Infrastructure**: [Docker, databases, external services needed]
```

## Quick Reference
```markdown
## Most Important Files (Read These First)
1. `[path]` - [why this file is critical]
2. `[path]` - [why this file is critical]
3. `[path]` - [why this file is critical]

## Common Commands
```bash
# Development
[command to start dev server]
[command to run tests]
[command to build]

# Debugging
[command to check logs]
[command to run in debug mode]

# Deployment
[command to deploy to staging]
[command to deploy to production]
```

## Linked Files
- [Link to main config file]
- [Link to API documentation]
- [Link to database schema]
- [Link to deployment guide]
```

---

## File Organization

### Project Documentation (for users):
- Root `.md` files - Project overview, installation, usage
- `docs/` directory - Technical documentation and guides
- `README.md` - Main project documentation

### AI Assistant Instructions (for Claude behavior):
- `.claude/` directory contains AI assistant behavioral instructions
- Always read relevant `.claude/*.md` files for context
- `.claude/settings.local.json` - Current permission settings

**IMPORTANT**: Files in `.claude/` are AI assistant instructions, not project documentation.

## Permissions & Settings

**⚠️ Read `.claude/settings.local.json` to understand current permission mode.**

### Permission System:
- **`allow`** - Commands Claude can execute freely
- **`ask`** - Commands that require user permission first
- **`deny`** - Commands that are completely blocked

### Template Modes:
```markdown
## Current Mode: [Safe Template / Local Installation Template]

### Safe Template (Development with Remote Installation)
- **Purpose**: Prevent local server modification
- **Allows**: git, gh, python, file operations, basic bash
- **Asks**: Destructive commands (rm -rf, git reset --hard)
- **Denies**: Installation commands (apt, npm install, make install)
- **Best for**: Projects using MCP servers for remote operations

### Local Installation Template  
- **Purpose**: Full local development capabilities
- **Allows**: Installation (apt install, make, cmake, cargo build)
- **Asks**: System-level destructive operations
- **Denies**: Network operations (ssh, curl, git push, docker push)
- **Best for**: Local development and compilation projects
```

### Key Commands by Permission:
```markdown
## Allowed Commands (Execute Freely):
- [List key commands that are always allowed]
- git status, git add, git commit
- python scripts, file operations
- [Add project-specific allowed commands]

## Ask Permission Commands (User Approval Required):
- [List commands that need permission]
- rm -rf, git reset --hard
- [Add project-specific ask commands]

## Denied Commands (Blocked):
- [List blocked commands and why]
- Installation commands (if safe mode)
- Network operations (if local mode)
- [Add project-specific denied commands]
```

## Task Management System

**⚠️ CRITICAL: Read `.claude/TASK-MANAGEMENT.md` for complete task management instructions.**

### Session Startup Procedure (CRITICAL)
**At the start of EVERY conversation, Claude must:**
1. **Read TODO.md** immediately to check for "In Progress" tasks
2. **Identify active work** from the "📋 Current Tasks (In Progress)" section  
3. **Prioritize these tasks** as the next work to be done
4. **Resume work** on these tasks unless user explicitly requests something else
5. **Update task status** as work progresses

### Task Commands:
- **"scan the tasks"** - Check GitHub Project, fetch tasks, present organized by status/priority
- **"show todo"** - Display complete TODO.md with status summary

### File Usage:
- **TODO.md** - Persistent task tracking (survives session restarts)
- **TodoWrite tool** - Temporary session-based todos
- **.claude/TASK-MANAGEMENT.md** - Complete workflow documentation

## Development Workflow System

**⚠️ Read `.claude/DEVELOPMENT-WORKFLOW.md` for complete development workflow.**

### Automatic Setup for Tasks
When user selects a task from "scan the tasks", Claude automatically:
1. **Creates GitHub issue** with proper labels and assignment
2. **Creates feature branch** with standardized naming
3. **Sets up work folder** (`work/issue-{number}/`) with README, NOTES, tests, docs
4. **Creates draft PR** linked to the issue

### Development Commands:
- **"git push"** - Intelligent branch detection and push
- **"make production"** / **"merge code"** - Complete merge and cleanup workflow
- **"start working on issue #123"** - Full setup workflow
- **"create hotfix"** - Emergency bug fix workflow

### Directory Structure:
```
project-root/
├── work/                    # Development workspace
│   ├── issue-123/          # Issue-specific folder
│   │   ├── README.md       # Task details and checklist
│   │   ├── NOTES.md        # Development notes
│   │   ├── tests/          # Issue-specific tests
│   │   └── docs/           # Issue documentation
├── src/                    # Main project source
├── tests/                  # Main project tests
└── docs/                   # Main project docs
```

---

## Usage Instructions

**For AI Assistants**: When working with this project:
1. **FIRST**: Read this CURSOR.MD file
2. **SECOND**: Read TODO.md to check for "In Progress" tasks
3. **THIRD**: Read `.claude/TASK-MANAGEMENT.md` and `.claude/DEVELOPMENT-WORKFLOW.md`
4. Only read additional files mentioned in "Linked Files" section initially
5. Follow the patterns and conventions described above
6. Respect the constraints in "What NOT to touch"
7. Use task management commands ("scan the tasks", "show todo") for workflow
8. Follow development workflow for bug/feature/enhancement tasks

**For Developers**: 
1. Update this file when project structure changes
2. Keep the "Current Focus" section updated
3. Add new patterns as they emerge
4. Update linked files when they change location
5. Use the install script to set up new projects with this system

**Template Version**: 2.0 (includes task management and development workflow)
**Last Updated**: [Date]
**Maintained By**: [Team/Person]
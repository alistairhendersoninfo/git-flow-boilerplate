---
layout: page
title: Getting Started
permalink: /getting-started/
---

# Getting Started

This guide will help you set up and use the Universal Git Flow Boilerplate system.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Git** (version 2.20+)
- **GitHub CLI** (`gh`) for repository management
- **Docker** (optional, for containerized development)
- **Node.js** (for JavaScript/React/Vue examples)
- **Python** (3.8+, for Python examples)
- **Rust** (latest stable, for Rust examples)
- **PHP** (7.4+, for PHP examples)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/git-flow-boilerplate.git
cd git-flow-boilerplate
```

### 2. Make Scripts Executable

```bash
chmod +x setup.sh
chmod +x scripts/*.sh
```

### 3. Initialize Your Project

Choose your primary language and framework:

```bash
# Python with Django
./setup.sh --language python --framework django --name my-project

# JavaScript with React
./setup.sh --language javascript --framework react --name my-app

# Rust with Actix Web
./setup.sh --language rust --framework actix --name my-service

# Vue.js application
./setup.sh --language vue --name my-vue-app
```

## Project Structure

After initialization, your project will have this structure:

```
my-project/
├── .github/
│   ├── workflows/          # CI/CD pipelines
│   └── ISSUE_TEMPLATE/     # Issue templates
├── docs/                   # Documentation source
├── src/                    # Source code
├── tests/                  # Test files
├── scripts/                # Automation scripts
├── README.md              # Project documentation
├── CONTRIBUTING.md        # Contribution guidelines
└── LICENSE               # License file
```

## Basic Usage

### Generate Documentation

```bash
# Generate all documentation
./scripts/generate-docs.sh

# Generate API documentation only
./scripts/generate-docs.sh --api-only

# Generate with Mermaid diagrams
./scripts/generate-docs.sh --include-diagrams
```

### Run Tests

```bash
# Run all tests
./scripts/run-tests.sh

# Run tests for specific language
./scripts/run-tests.sh --language python

# Run with coverage
./scripts/run-tests.sh --coverage
```

### Build Project

```bash
# Build all components
./scripts/build-all.sh

# Build for production
./scripts/build-all.sh --production

# Build specific component
./scripts/build-all.sh --component api
```

## Git Flow Workflow

This boilerplate implements a standard Git Flow workflow:

```mermaid
graph TD
    A[main branch] --> B[develop branch]
    B --> C[feature/branch]
    B --> D[release/branch]
    B --> E[hotfix/branch]
    C --> B
    D --> A
    D --> B
    E --> A
    E --> B
```

### Creating Features

```bash
# Start a new feature
git checkout develop
git checkout -b feature/my-new-feature

# Work on your feature
git add .
git commit -m "Add new feature"

# Push and create PR
git push -u origin feature/my-new-feature
gh pr create --title "Add new feature" --body "Description of changes"
```

### Creating Releases

```bash
# Start a release
git checkout develop
git checkout -b release/v1.0.0

# Update version numbers and documentation
./scripts/prepare-release.sh v1.0.0

# Merge to main
git checkout main
git merge release/v1.0.0
git tag v1.0.0
git push origin main --tags
```

## Configuration

### Environment Variables

Create a `.env` file in your project root:

```bash
# Development settings
NODE_ENV=development
DEBUG=true

# Database settings
DATABASE_URL=postgresql://user:pass@localhost/dbname

# API settings
API_PORT=3000
API_HOST=localhost
```

### GitHub Actions

The boilerplate includes pre-configured workflows:

- **CI Pipeline** - Runs tests on every PR
- **Documentation** - Updates GitHub Pages on main branch changes
- **Release** - Creates releases and publishes packages
- **Security** - Scans for vulnerabilities

## Customization

### Adding New Languages

1. Create directory structure:
```bash
mkdir -p examples/newlang templates/newlang
```

2. Add hello world example:
```bash
# Create examples/newlang/hello.ext
# Add to templates/newlang/
```

3. Update workflows:
```bash
# Add to .github/workflows/ci.yml
# Update scripts/run-tests.sh
```

### Modifying Documentation

1. Edit files in `docs/` directory
2. Run `./scripts/generate-docs.sh`
3. Commit and push changes

### Custom Workflows

Add new GitHub Actions workflows in `.github/workflows/`:

```yaml
name: Custom Workflow
on:
  push:
    branches: [ main ]
jobs:
  custom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Custom Step
        run: echo "Custom action"
```

## Troubleshooting

### Common Issues

**Permission Denied on Scripts**
```bash
chmod +x setup.sh scripts/*.sh
```

**Missing Dependencies**
```bash
# Check requirements for your language
./scripts/check-requirements.sh
```

**Documentation Not Building**
```bash
# Check Jekyll configuration
bundle exec jekyll doctor
```

### Getting Help

- Check the [FAQ](faq.md)
- Browse [Examples](examples/)
- Open an [Issue](https://github.com/your-username/git-flow-boilerplate/issues)
- Join our [Discussions](https://github.com/your-username/git-flow-boilerplate/discussions)

## Next Steps

1. [Explore Language Examples](languages/)
2. [Set Up CI/CD Workflows](workflows/)
3. [Customize Your Documentation](api/)
4. [Contribute to the Project](CONTRIBUTING.md)
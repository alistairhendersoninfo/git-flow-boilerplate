#!/usr/bin/env bash
#
# setup-gitdocs.sh
# Creates a documentation site like docs.github.com
# Simple - just write MD files and get a professional docs site

set -euo pipefail

# Get project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$PROJECT_ROOT"

# Load environment variables from .claude/.env
CLAUDE_DIR="$PROJECT_ROOT/.claude"
if [[ -f "$CLAUDE_DIR/.env" ]]; then
    set -a  # Export all variables
    source "$CLAUDE_DIR/.env"
    set +a  # Stop exporting
fi

# Get project name from directory
PROJECT_NAME=$(basename "$PROJECT_ROOT")

# Use stored GitHub username or fallback
GITHUB_USER="${GITHUB_USERNAME:-yourusername}"
SITE_URL="https://${GITHUB_USER}.github.io/${PROJECT_NAME}/"

echo "🏗️  Setting Up GitDocs (Documentation Site)"
echo "============================================"
echo ""

# Create docs structure
mkdir -p docs/guides
mkdir -p docs/api
mkdir -p docs/tutorials

# Install MkDocs with Material theme (looks like GitHub docs)
echo "📦 Installing MkDocs (creates GitHub-style docs)..."
if command -v pip3 &> /dev/null; then
    pip3 install --user mkdocs mkdocs-material mkdocs-awesome-pages-plugin
    echo "✅ MkDocs installed"
elif command -v pip &> /dev/null; then
    pip install --user mkdocs mkdocs-material mkdocs-awesome-pages-plugin
    echo "✅ MkDocs installed"
else
    echo "❌ Python/pip not found. Install Python first."
    exit 1
fi

# Create MkDocs config that looks like GitHub docs
echo "🔧 Creating MkDocs configuration..."
echo "   📱 GitHub user: $GITHUB_USER"
echo "   🌐 Site URL: $SITE_URL"
echo "   📁 Project: $PROJECT_NAME"

# Use template if available, otherwise create basic config
if [[ -f "$CLAUDE_DIR/templates/mkdocs.yml" ]]; then
    echo "   📋 Using mkdocs.yml template..."
    # Copy template and substitute variables
    sed -e "s/PROJECT_NAME/${PROJECT_NAME}/g" \
        -e "s/GITHUB_USERNAME/${GITHUB_USER}/g" \
        "$CLAUDE_DIR/templates/mkdocs.yml" > mkdocs.yml
else
    echo "   📋 Creating basic mkdocs.yml..."
    cat > mkdocs.yml << EOF
site_name: ${PROJECT_NAME} Documentation
site_description: Complete ${PROJECT_NAME} documentation
site_url: ${SITE_URL}

theme:
  name: material
  palette:
    - scheme: default
      primary: blue
      accent: blue
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: blue
      accent: blue
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.top
    - search.highlight
    - search.share
    - content.code.copy

nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - Guides: guides/
  - API Reference: api/
  - Tutorials: tutorials/

plugins:
  - search
  - awesome-pages

markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.inlinehilite
  - pymdownx.snippets
  - pymdownx.tabbed:
      alternate_style: true
  - toc:
      permalink: true
EOF

# Create initial docs
cat > docs/index.md << 'EOF'
# Welcome to Our Documentation

This is the main documentation site for the project.

## Quick Start

Get started quickly with our [Getting Started Guide](getting-started.md).

## What's Available

- **[Guides](guides/)** - Step-by-step instructions
- **[API Reference](api/)** - Technical API documentation  
- **[Tutorials](tutorials/)** - Learn by example

## Need Help?

Check out our guides or contact support.
EOF

cat > docs/getting-started.md << 'EOF'
# Getting Started

Welcome! This guide will help you get up and running quickly.

## Prerequisites

Before you begin, make sure you have:

- Item 1
- Item 2
- Item 3

## Installation

Follow these steps:

1. Step one
2. Step two  
3. Step three

## Next Steps

After installation, check out our [Guides](guides/) section.
EOF

mkdir -p docs/guides
cat > docs/guides/index.md << 'EOF'
# Guides

This section contains step-by-step guides for common tasks.

## Available Guides

- [Your First Guide](first-guide.md)
- More guides coming soon...
EOF

cat > docs/guides/first-guide.md << 'EOF'
# Your First Guide

This is an example guide. Replace this content with your actual documentation.

## Overview

Explain what this guide covers.

## Steps

### Step 1: Do Something

Details about step 1.

### Step 2: Do Something Else

Details about step 2.

## Conclusion

Wrap up the guide.
EOF

echo ""
echo "✅ GitDocs Setup Complete!"
echo ""
echo "Your documentation site is ready:"
echo "📁 Write docs in: docs/"
echo "🌐 Preview with: mkdocs serve"
echo "🚀 Build with: mkdocs build"
echo ""
echo "Next steps:"
echo "1. Edit docs/index.md to customize homepage"
echo "2. Add your guides in docs/guides/"
echo "3. Run 'mkdocs serve' to preview"
echo "4. When ready, run setup-gitpages.sh for marketing site"
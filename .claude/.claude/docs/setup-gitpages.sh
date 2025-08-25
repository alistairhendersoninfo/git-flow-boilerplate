#!/usr/bin/env bash
#
# setup-gitpages.sh  
# Creates a marketing website that includes your GitDocs
# This is your main website with docs integrated

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

echo "🌐 Setting Up GitPages (Marketing Site + Docs)"
echo "==============================================="
echo ""

# Check if GitDocs exists
if [[ ! -f "mkdocs.yml" ]]; then
    echo "❌ GitDocs not found. Run setup-gitdocs.sh first!"
    exit 1
fi

echo "📋 Choose your marketing site type:"
echo "1) Simple HTML pages (easy to edit)"
echo "2) Jekyll (GitHub Pages default)"
echo "3) Just enable docs on GitHub Pages (no marketing)"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo "🏗️  Creating simple HTML marketing site..."
        
        # Create marketing homepage
        cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Name</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; 
            line-height: 1.6; 
            max-width: 800px; 
            margin: 0 auto; 
            padding: 20px;
            background: #f8f9fa;
        }
        .header { 
            text-align: center; 
            padding: 60px 0; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            margin: -20px -20px 40px -20px;
            border-radius: 0 0 20px 20px;
        }
        .cta-button { 
            display: inline-block; 
            background: #28a745; 
            color: white; 
            padding: 15px 30px; 
            text-decoration: none; 
            border-radius: 5px; 
            font-weight: bold;
            margin: 10px;
        }
        .feature { 
            background: white; 
            padding: 20px; 
            margin: 20px 0; 
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Your Project Name</h1>
        <p>One-line description of what your project does</p>
        <a href="docs/" class="cta-button">📚 View Documentation</a>
        <a href="#features" class="cta-button">✨ Learn More</a>
    </div>

    <div id="features">
        <div class="feature">
            <h3>🎯 Feature 1</h3>
            <p>Describe your main feature here.</p>
        </div>
        
        <div class="feature">
            <h3>⚡ Feature 2</h3>
            <p>Describe another key feature.</p>
        </div>
        
        <div class="feature">
            <h3>🔧 Easy to Use</h3>
            <p>Check out our <a href="docs/">documentation</a> to get started in minutes.</p>
        </div>
    </div>

    <div style="text-align: center; margin-top: 40px;">
        <a href="docs/" class="cta-button">📚 Read the Docs</a>
        <a href="https://github.com/yourusername/yourproject" class="cta-button">⭐ Star on GitHub</a>
    </div>
</body>
</html>
EOF

        # Create about page
        cat > about.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - Project Name</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; 
            line-height: 1.6; 
            max-width: 800px; 
            margin: 0 auto; 
            padding: 20px;
        }
        nav { background: #333; padding: 10px 0; margin: -20px -20px 20px -20px; }
        nav a { color: white; margin: 0 15px; text-decoration: none; }
    </style>
</head>
<body>
    <nav>
        <a href="/">Home</a>
        <a href="/about.html">About</a>
        <a href="/docs/">Documentation</a>
    </nav>
    
    <h1>About Our Project</h1>
    <p>Tell your project's story here.</p>
    
    <h2>The Team</h2>
    <p>Information about who built this.</p>
    
    <h2>Get Involved</h2>
    <p>Want to contribute? Check out our <a href="docs/">documentation</a> for developer guides.</p>
</body>
</html>
EOF
        
        echo "✅ Simple HTML marketing site created"
        ;;
        
    2)
        echo "🏗️  Creating Jekyll marketing site..."
        
        # Create Jekyll config
        cat > _config.yml << 'EOF'
title: Your Project Name
description: One-line description of your project
baseurl: ""
url: "https://yourusername.github.io"

theme: minima

plugins:
  - jekyll-feed
  - jekyll-seo-tag

collections:
  docs:
    output: true
    permalink: /docs/:path/

defaults:
  - scope:
      path: ""
      type: posts
    values:
      layout: post
  - scope:
      path: ""
      type: pages
    values:
      layout: page
EOF

        # Create Jekyll homepage
        cat > index.md << 'EOF'
---
layout: home
title: Home
---

# 🚀 Welcome to Your Project

One-line description of what your project does.

## Quick Start

Get started in minutes:

1. [Check out our documentation](docs/)
2. Follow the getting started guide
3. Build something amazing!

## Features

- ✨ Feature 1
- ⚡ Feature 2  
- 🔧 Easy to use

## Documentation

Our comprehensive [documentation](docs/) covers everything you need to know.

---

[📚 View Documentation](docs/){: .btn .btn-primary}
[⭐ Star on GitHub](https://github.com/yourusername/yourproject){: .btn}
EOF

        # Create about page
        cat > about.md << 'EOF'
---
layout: page
title: About
---

# About Our Project

Tell your project's story here.

## The Mission

Explain what problem you're solving.

## The Team

Information about who built this.

## Get Involved

Want to contribute? Check out our [documentation](docs/) for developer guides.
EOF
        
        echo "✅ Jekyll marketing site created"
        ;;
        
    3)
        echo "🏗️  Setting up docs-only GitHub Pages..."
        
        # Create simple redirect
        cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="0; url=docs/">
    <title>Redirecting to Documentation</title>
</head>
<body>
    <p>Redirecting to <a href="docs/">documentation</a>...</p>
</body>
</html>
EOF
        
        echo "✅ Docs-only setup created (redirects to docs/)"
        ;;
esac

# Setup GitHub Pages
echo ""
echo "📄 Creating GitHub Actions for automatic deployment..."
mkdir -p .github/workflows

cat > .github/workflows/pages.yml << 'EOF'
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
        
    - name: Install MkDocs
      run: |
        pip install mkdocs mkdocs-material mkdocs-awesome-pages-plugin
        
    - name: Build documentation
      run: mkdocs build
      
    - name: Setup Pages
      uses: actions/configure-pages@v3
      
    - name: Upload Pages artifact
      uses: actions/upload-pages-artifact@v2
      with:
        path: site/
        
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
      
    steps:
    - name: Deploy to GitHub Pages
      id: deployment
      uses: actions/deploy-pages@v2
EOF

echo ""
echo "✅ GitPages Setup Complete!"
echo ""
echo "🎉 Your marketing site with integrated docs is ready!"
echo ""
echo "Next steps:"
echo "1. Edit index.html (or index.md) to customize your homepage"
echo "2. Update project name and description"
echo "3. Push to GitHub"
echo "4. Enable GitHub Pages in repository Settings → Pages"
echo ""
echo "Your site structure:"
echo "📁 / = Marketing website"  
echo "📁 /docs/ = Documentation (from GitDocs)"
echo ""
echo "URLs will be:"
echo "🌐 https://yourusername.github.io/projectname/ = Marketing"
echo "📚 https://yourusername.github.io/projectname/docs/ = Docs"
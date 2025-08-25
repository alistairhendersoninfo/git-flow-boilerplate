#!/usr/bin/env bash
#
# create_git_documentation.sh
# Main script to create complete Git documentation setup
# This is the ONE script you run to get documentation working

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Git Documentation Creator${NC}"
echo "=================================="
echo ""
echo "This script creates a complete documentation system:"
echo ""
echo -e "${GREEN}1. GitDocs${NC} - Professional documentation site (like docs.github.com)"
echo -e "${GREEN}2. GitPages${NC} - Marketing website that includes your docs"
echo -e "${GREEN}3. Advanced Tools${NC} - Generate docs from code (PHP, Python, JS, etc.)"
echo ""
echo "You'll get:"
echo "✅ Write markdown files → Beautiful documentation site"
echo "✅ Marketing website with integrated docs"
echo "✅ Automatic documentation from code comments"
echo "✅ Professional GitHub Pages deployment"
echo ""
read -p "Ready to create your documentation system? [Y/n]: " continue_setup
if [[ "$continue_setup" =~ ^[Nn]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Creating GitDocs (Documentation Site)${NC}"
echo "================================================"
echo ""
echo "This creates a professional documentation site like docs.github.com"
echo "You'll be able to write markdown files and get a beautiful docs site."
echo ""
read -p "Create GitDocs? [Y/n]: " create_gitdocs

if [[ ! "$create_gitdocs" =~ ^[Nn]$ ]]; then
    echo "🏗️  Running GitDocs setup..."
    ./docs/setup-gitdocs.sh
    echo -e "${GREEN}✅ GitDocs created!${NC}"
else
    echo "⏭️  Skipping GitDocs"
fi

echo ""
echo -e "${BLUE}Step 2: Creating GitPages (Marketing Site)${NC}"
echo "=============================================="
echo ""
echo "This creates a marketing website that includes your documentation."
echo "Your site will have both marketing pages AND documentation."
echo ""
read -p "Create GitPages marketing site? [Y/n]: " create_gitpages

if [[ ! "$create_gitpages" =~ ^[Nn]$ ]]; then
    echo "🌐 Running GitPages setup..."
    ./docs/setup-gitpages.sh
    echo -e "${GREEN}✅ GitPages created!${NC}"
else
    echo "⏭️  Skipping GitPages"
fi

echo ""
echo -e "${BLUE}Step 3: Advanced Documentation Tools${NC}"
echo "========================================="
echo ""
echo "These tools generate API documentation from your code comments."
echo "Only needed if you have PHP, Python, JavaScript, TypeScript, etc."
echo ""
echo -e "${YELLOW}Note: You can skip this and install later when you have code.${NC}"
echo ""
read -p "Install advanced code documentation tools? [y/N]: " install_advanced

if [[ "$install_advanced" =~ ^[Yy]$ ]]; then
    echo "🔧 Installing advanced documentation tools..."
    ./docs/install-advanced-doc-tools.sh
    echo -e "${GREEN}✅ Advanced tools installed!${NC}"
else
    echo "⏭️  Skipping advanced tools (you can install later)"
fi

echo ""
echo -e "${GREEN}🎉 Git Documentation Setup Complete!${NC}"
echo ""
echo "What you now have:"
echo "📚 Documentation site - Write .md files, get beautiful docs"
echo "🌐 Marketing website - Professional site with integrated docs"
echo "🔧 Code documentation - Auto-generate docs from code (if installed)"
echo ""
echo "Next steps:"
echo "1️⃣  Write documentation in docs/ folder"
echo "2️⃣  Preview with: mkdocs serve"
echo "3️⃣  Commit and push to GitHub"
echo "4️⃣  Enable GitHub Pages in repository Settings"
echo ""
echo "Your documentation will be available at:"
echo "🌐 Marketing: https://yourusername.github.io/projectname/"
echo "📚 Docs: https://yourusername.github.io/projectname/docs/"
echo ""
echo -e "${BLUE}Happy documenting! 📝${NC}"
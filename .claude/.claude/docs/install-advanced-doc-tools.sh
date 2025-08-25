#!/usr/bin/env bash
#
# install-advanced-doc-tools.sh
# Installs tools for generating docs from code (PHP, Python, JS, etc.)
# Only run this when you have code that needs API documentation

set -euo pipefail

echo "🔧 Installing Advanced Documentation Tools"
echo "==========================================="
echo ""
echo "These tools generate documentation from your code comments."
echo "Only install if you need to document APIs/code (not just MD files)."
echo ""

# Detect what languages are in the project
echo "🔍 Detecting project languages..."
LANGS=()
[[ -f "composer.json" || -n "$(find . -name '*.php' -type f 2>/dev/null | head -1)" ]] && LANGS+=("PHP")
[[ -f "requirements.txt" || -f "setup.py" || -n "$(find . -name '*.py' -type f 2>/dev/null | head -1)" ]] && LANGS+=("Python")
[[ -f "package.json" ]] && LANGS+=("JavaScript/Node")
[[ -f "tsconfig.json" ]] && LANGS+=("TypeScript")
[[ -f "Cargo.toml" ]] && LANGS+=("Rust")
[[ -f "angular.json" ]] && LANGS+=("Angular")

if [[ ${#LANGS[@]} -eq 0 ]]; then
    echo "❓ No code files detected - you probably don't need these tools yet."
    echo "   Just use setup-gitdocs.sh for writing documentation in MD files."
    echo ""
    read -p "Install anyway? [y/N]: " install_anyway
    if [[ ! "$install_anyway" =~ ^[Yy]$ ]]; then
        echo "Skipping advanced tools installation."
        exit 0
    fi
else
    echo "✅ Detected: ${LANGS[*]}"
    echo ""
    read -p "Install documentation tools for these languages? [Y/n]: " continue
    if [[ "$continue" =~ ^[Nn]$ ]]; then
        echo "Skipping installation."
        exit 0
    fi
fi

echo ""
echo "📦 Installing tools..."

# Install based on detected languages
for lang in "${LANGS[@]}"; do
    case "$lang" in
        "PHP")
            echo "📘 Installing PHP documentation tools..."
            if ! command -v phpdoc &> /dev/null; then
                curl -sSL https://phpdoc.org/phpDocumentor.phar -o /tmp/phpdoc.phar
                chmod +x /tmp/phpdoc.phar
                sudo mv /tmp/phpdoc.phar /usr/local/bin/phpdoc
                echo "  ✅ phpDocumentor installed"
            else
                echo "  ✅ phpDocumentor already installed"
            fi
            ;;
            
        "Python")
            echo "🐍 Installing Python documentation tools..."
            if command -v pip3 &> /dev/null; then
                pip3 install --user sphinx sphinx-rtd-theme
                echo "  ✅ Sphinx installed"
            elif command -v pip &> /dev/null; then
                pip install --user sphinx sphinx-rtd-theme  
                echo "  ✅ Sphinx installed"
            else
                echo "  ❌ Python pip not found"
            fi
            ;;
            
        "JavaScript/Node")
            echo "📦 Installing JavaScript documentation tools..."
            if command -v npm &> /dev/null; then
                npm install -g jsdoc
                echo "  ✅ JSDoc installed"
            else
                echo "  ❌ npm not found"
            fi
            ;;
            
        "TypeScript")
            echo "📦 Installing TypeScript documentation tools..."
            if command -v npm &> /dev/null; then
                npm install -g typedoc
                echo "  ✅ TypeDoc installed"
            else
                echo "  ❌ npm not found"  
            fi
            ;;
            
        "Angular")
            echo "📦 Installing Angular documentation tools..."
            if command -v npm &> /dev/null; then
                npm install -g @compodoc/compodoc
                echo "  ✅ Compodoc installed"
            else
                echo "  ❌ npm not found"
            fi
            ;;
            
        "Rust")
            echo "🦀 Rust documentation tools..."
            echo "  ✅ rustdoc (built-in with Rust)"
            ;;
    esac
done

echo ""
echo "✅ Advanced documentation tools installed!"
echo ""
echo "💡 How to use:"
echo "   - Write code comments in your source files"
echo "   - Run 'mkdocs build' - it will auto-generate API docs"
echo "   - Your GitDocs site will include both MD files AND code docs"
echo ""
echo "📚 Example comment formats:"
echo "   PHP:        /** @param string \$name */  "
echo "   Python:     '''Args: name (str): Description'''"
echo "   JavaScript: /** @param {string} name - Description */"
echo "   TypeScript: /** @param name - Description */"
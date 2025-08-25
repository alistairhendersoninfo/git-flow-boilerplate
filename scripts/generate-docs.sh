#!/bin/bash
# Universal Documentation Generation Script
# Generates documentation for all languages and formats

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$PROJECT_ROOT/docs"
EXAMPLES_DIR="$PROJECT_ROOT/examples"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GENERATE_API_DOCS=true
GENERATE_MERMAID=true
GENERATE_README=true
INCLUDE_EXAMPLES=true
OUTPUT_FORMAT="html"
VERBOSE=false

# Function to log messages
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Function to show usage
show_usage() {
    cat << EOF
Universal Documentation Generation Script

Usage: $0 [OPTIONS]

Options:
    --all                   Generate all documentation (default)
    --api-only             Generate only API documentation
    --readme-only          Generate only README files
    --mermaid-only         Generate only Mermaid diagrams
    --no-api               Skip API documentation
    --no-mermaid           Skip Mermaid diagrams
    --no-readme            Skip README generation
    --no-examples          Skip example documentation
    --format FORMAT        Output format: html, pdf, markdown (default: html)
    --output DIR           Output directory (default: docs/)
    --verbose              Verbose output
    --help                 Show this help message

Examples:
    $0                     # Generate all documentation
    $0 --api-only          # Generate only API docs
    $0 --format pdf        # Generate PDF documentation
    $0 --no-mermaid        # Skip diagram generation
    $0 --verbose           # Verbose output

Supported Languages:
    - Rust (cargo doc, rustdoc)
    - Python (Sphinx, autodoc)
    - Node.js (JSDoc, TypeDoc)
    - PHP (phpDocumentor)
    - Bash (manual documentation)
    - JavaScript (JSDoc)
    - React (Storybook, Docusaurus)
    - Vue.js (VuePress)
EOF
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for required tools
    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if [[ "$GENERATE_MERMAID" == true ]] && ! command -v mmdc &> /dev/null; then
        log_warning "Mermaid CLI not found, trying to install..."
        if command -v npm &> /dev/null; then
            npm install -g @mermaid-js/mermaid-cli || missing_deps+=("@mermaid-js/mermaid-cli")
        else
            missing_deps+=("@mermaid-js/mermaid-cli")
        fi
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Please install the missing dependencies and try again"
        return 1
    fi
    
    return 0
}

# Function to generate Rust documentation
generate_rust_docs() {
    log "Generating Rust documentation..."
    
    local rust_dir="$EXAMPLES_DIR/rust"
    if [[ ! -d "$rust_dir" ]]; then
        log_warning "Rust example directory not found: $rust_dir"
        return 0
    fi
    
    cd "$rust_dir"
    
    # Generate cargo docs
    if command -v cargo &> /dev/null; then
        log "Running cargo doc..."
        cargo doc --no-deps --document-private-items || log_warning "Cargo doc failed"
        
        # Copy generated docs to main docs directory
        if [[ -d "target/doc" ]]; then
            mkdir -p "$DOCS_DIR/api/rust"
            cp -r target/doc/* "$DOCS_DIR/api/rust/" || log_warning "Failed to copy Rust docs"
            log_success "Rust documentation generated"
        fi
    else
        log_warning "Cargo not found, skipping Rust documentation"
    fi
    
    cd "$PROJECT_ROOT"
}

# Function to generate Python documentation
generate_python_docs() {
    log "Generating Python documentation..."
    
    local python_dir="$EXAMPLES_DIR/python"
    if [[ ! -d "$python_dir" ]]; then
        log_warning "Python example directory not found: $python_dir"
        return 0
    fi
    
    cd "$python_dir"
    
    # Check if Sphinx is available
    if command -v sphinx-build &> /dev/null || python3 -c "import sphinx" 2>/dev/null; then
        log "Generating Sphinx documentation..."
        
        # Create Sphinx configuration if it doesn't exist
        if [[ ! -f "conf.py" ]]; then
            cat > conf.py << 'EOF'
import os
import sys
sys.path.insert(0, os.path.abspath('.'))

project = 'Python Hello World'
copyright = '2024, Development Team'
author = 'Development Team'
release = '1.0.0'

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon'
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
EOF
        fi
        
        # Generate documentation
        mkdir -p "$DOCS_DIR/api/python"
        sphinx-build -b html . "$DOCS_DIR/api/python" || log_warning "Sphinx build failed"
        log_success "Python documentation generated"
    else
        log_warning "Sphinx not found, generating simple Python docs..."
        
        # Generate simple documentation using pydoc
        mkdir -p "$DOCS_DIR/api/python"
        python3 -m pydoc -w hello server 2>/dev/null || true
        mv *.html "$DOCS_DIR/api/python/" 2>/dev/null || true
    fi
    
    cd "$PROJECT_ROOT"
}

# Function to generate Node.js documentation
generate_nodejs_docs() {
    log "Generating Node.js documentation..."
    
    local nodejs_dir="$EXAMPLES_DIR/nodejs"
    if [[ ! -d "$nodejs_dir" ]]; then
        log_warning "Node.js example directory not found: $nodejs_dir"
        return 0
    fi
    
    cd "$nodejs_dir"
    
    # Check if JSDoc is available
    if command -v jsdoc &> /dev/null || npm list jsdoc &> /dev/null; then
        log "Running JSDoc..."
        
        # Create JSDoc configuration
        cat > jsdoc.conf.json << 'EOF'
{
    "source": {
        "include": ["./"],
        "includePattern": "\\.(js|jsx)$",
        "exclude": ["node_modules/", "test/"]
    },
    "opts": {
        "destination": "./docs/"
    },
    "plugins": ["plugins/markdown"]
}
EOF
        
        # Generate documentation
        mkdir -p "$DOCS_DIR/api/nodejs"
        jsdoc -c jsdoc.conf.json -d "$DOCS_DIR/api/nodejs" || log_warning "JSDoc failed"
        log_success "Node.js documentation generated"
    else
        log_warning "JSDoc not found, skipping Node.js documentation"
    fi
    
    cd "$PROJECT_ROOT"
}

# Function to generate PHP documentation
generate_php_docs() {
    log "Generating PHP documentation..."
    
    local php_dir="$EXAMPLES_DIR/php"
    if [[ ! -d "$php_dir" ]]; then
        log_warning "PHP example directory not found: $php_dir"
        return 0
    fi
    
    cd "$php_dir"
    
    # Check if phpDocumentor is available
    if command -v phpdoc &> /dev/null; then
        log "Running phpDocumentor..."
        mkdir -p "$DOCS_DIR/api/php"
        phpdoc -d . -t "$DOCS_DIR/api/php" || log_warning "phpDocumentor failed"
        log_success "PHP documentation generated"
    else
        log_warning "phpDocumentor not found, skipping PHP documentation"
    fi
    
    cd "$PROJECT_ROOT"
}

# Function to generate Bash documentation
generate_bash_docs() {
    log "Generating Bash documentation..."
    
    local bash_dir="$EXAMPLES_DIR/bash"
    if [[ ! -d "$bash_dir" ]]; then
        log_warning "Bash example directory not found: $bash_dir"
        return 0
    fi
    
    # Generate manual documentation for Bash scripts
    mkdir -p "$DOCS_DIR/api/bash"
    
    cat > "$DOCS_DIR/api/bash/index.md" << 'EOF'
# Bash Hello World Documentation

## Scripts

### hello.sh
A comprehensive Hello World CLI application in Bash with multi-language support.

**Usage:**
```bash
./hello.sh [OPTIONS]
```

**Options:**
- `-n, --name NAME` - Name to greet (default: World)
- `-f, --format FORMAT` - Output format: text, json (default: text)
- `-l, --language LANG` - Language code (default: en)
- `--list-languages` - List available languages
- `-h, --help` - Show help message
- `-v, --version` - Show version

### server.sh
A simple HTTP server implementation using netcat.

**Usage:**
```bash
./server.sh [OPTIONS]
```

**Options:**
- `-p, --port PORT` - Port to listen on (default: 8080)
- `-h, --host HOST` - Host to bind to (default: 127.0.0.1)
- `--help` - Show help message

## Functions

### Core Functions
- `generate_greeting()` - Generate greeting message
- `get_timestamp()` - Get ISO format timestamp
- `validate_language()` - Validate language support
- `parse_args()` - Parse command line arguments

### Server Functions
- `handle_request()` - Process HTTP requests
- `handle_greet()` - Handle greeting endpoints
- `handle_health()` - Handle health check
- `handle_languages()` - Handle language listing

## Supported Languages
- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt)
- Russian (ru)
- Japanese (ja)
- Chinese (zh)
EOF
    
    log_success "Bash documentation generated"
}

# Function to generate Mermaid diagrams
generate_mermaid_diagrams() {
    if [[ "$GENERATE_MERMAID" != true ]]; then
        return 0
    fi
    
    log "Generating Mermaid diagrams..."
    
    mkdir -p "$DOCS_DIR/diagrams"
    
    # Git Flow diagram
    cat > "$DOCS_DIR/diagrams/gitflow.mmd" << 'EOF'
gitGraph
    commit id: "Initial"
    branch develop
    checkout develop
    commit id: "Setup"
    branch feature/rust
    checkout feature/rust
    commit id: "Add Rust"
    commit id: "Add Tests"
    checkout develop
    merge feature/rust
    branch feature/python
    checkout feature/python
    commit id: "Add Python"
    commit id: "Add FastAPI"
    checkout develop
    merge feature/python
    commit id: "Update Docs"
    checkout main
    merge develop
    commit id: "Release v1.0"
EOF
    
    # Architecture diagram
    cat > "$DOCS_DIR/diagrams/architecture.mmd" << 'EOF'
graph TB
    A[Git Flow Boilerplate] --> B[Multi-Language Examples]
    A --> C[Documentation System]
    A --> D[CI/CD Workflows]
    A --> E[Project Templates]
    
    B --> B1[Rust]
    B --> B2[Python]
    B --> B3[Node.js]
    B --> B4[PHP]
    B --> B5[Bash]
    B --> B6[JavaScript]
    B --> B7[React]
    B --> B8[Vue.js]
    
    C --> C1[GitHub Pages]
    C --> C2[API Docs]
    C --> C3[Mermaid Diagrams]
    C --> C4[Interactive Examples]
    
    D --> D1[Testing Pipeline]
    D --> D2[Documentation Deploy]
    D --> D3[Security Scanning]
    D --> D4[Release Automation]
    
    E --> E1[Language Templates]
    E --> E2[Framework Boilerplates]
    E --> E3[Setup Scripts]
    E --> E4[Configuration Files]
EOF
    
    # API Flow diagram
    cat > "$DOCS_DIR/diagrams/api-flow.mmd" << 'EOF'
sequenceDiagram
    participant C as Client
    participant API as Hello API
    participant S as Greeting Service
    participant L as Language DB
    
    C->>API: GET /greet?name=User&lang=es
    API->>S: greet("User", "es")
    S->>L: getTemplate("es")
    L-->>S: "¡Hola, {}!"
    S-->>API: "¡Hola, User!"
    API-->>C: {"message": "¡Hola, User!", ...}
EOF
    
    # Generate PNG images from Mermaid files
    if command -v mmdc &> /dev/null; then
        for mmd_file in "$DOCS_DIR/diagrams"/*.mmd; do
            if [[ -f "$mmd_file" ]]; then
                local base_name=$(basename "$mmd_file" .mmd)
                log "Generating diagram: $base_name"
                mmdc -i "$mmd_file" -o "$DOCS_DIR/diagrams/$base_name.png" || log_warning "Failed to generate $base_name diagram"
            fi
        done
        log_success "Mermaid diagrams generated"
    else
        log_warning "Mermaid CLI not found, skipping diagram generation"
    fi
}

# Function to generate README files
generate_readme_files() {
    if [[ "$GENERATE_README" != true ]]; then
        return 0
    fi
    
    log "Generating README files..."
    
    # Main project README
    cat > "$PROJECT_ROOT/README.md" << 'EOF'
# Universal Git Flow Boilerplate

[![CI](https://github.com/your-username/git-flow-boilerplate/workflows/CI/badge.svg)](https://github.com/your-username/git-flow-boilerplate/actions)
[![Documentation](https://github.com/your-username/git-flow-boilerplate/workflows/Documentation/badge.svg)](https://your-username.github.io/git-flow-boilerplate)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive boilerplate system that provides standardized project templates, automated documentation generation, GitHub Pages integration, and multi-language support for modern development workflows.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/your-username/git-flow-boilerplate.git
cd git-flow-boilerplate

# Initialize a new project
./setup.sh --language python --framework django

# Generate documentation
./scripts/generate-docs.sh

# Run tests
./scripts/run-tests.sh
```

## 🌟 Features

### Multi-Language Support
- **Rust** - Systems programming with Cargo
- **Python** - Web development with Django/Flask
- **JavaScript/Node.js** - Full-stack development
- **React** - Modern frontend development
- **Vue.js** - Progressive frontend framework
- **PHP** - Web development with Composer
- **Bash** - Shell scripting and automation

### Automated Documentation
- **GitHub Pages** integration
- **API Documentation** generation
- **Mermaid Diagrams** support
- **Multi-format** output (HTML, PDF, Markdown)

### CI/CD Workflows
- **Automated Testing** across all languages
- **Documentation Deployment** 
- **Multi-environment** support
- **Security Scanning**

## 📚 Documentation

- [Getting Started](https://your-username.github.io/git-flow-boilerplate/getting-started)
- [Language Examples](https://your-username.github.io/git-flow-boilerplate/languages)
- [API Documentation](https://your-username.github.io/git-flow-boilerplate/api)
- [Workflows](https://your-username.github.io/git-flow-boilerplate/workflows)

## 🏗️ Project Structure

```
git-flow-boilerplate/
├── .github/workflows/      # CI/CD pipelines
├── docs/                   # Documentation source
├── examples/               # Language examples
├── templates/              # Project templates
├── scripts/                # Automation scripts
└── workflows/              # Git flow configurations
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
EOF
    
    # Generate language-specific READMEs
    for lang_dir in "$EXAMPLES_DIR"/*; do
        if [[ -d "$lang_dir" ]]; then
            local lang_name=$(basename "$lang_dir")
            generate_language_readme "$lang_name" "$lang_dir"
        fi
    done
    
    log_success "README files generated"
}

# Function to generate language-specific README
generate_language_readme() {
    local lang_name="$1"
    local lang_dir="$2"
    
    case "$lang_name" in
        "rust")
            cat > "$lang_dir/README.md" << 'EOF'
# Rust Hello World Example

A comprehensive Hello World implementation in Rust with CLI and server components.

## Features

- Command-line interface with argument parsing
- HTTP server using Actix Web
- Multi-language greeting support
- JSON output format
- Comprehensive test suite
- API documentation

## Usage

### CLI Application

```bash
# Build the project
cargo build

# Run with default settings
cargo run --bin hello

# Custom greeting
cargo run --bin hello -- --name "Rust" --language "es"

# JSON output
cargo run --bin hello -- --format json
```

### HTTP Server

```bash
# Start the server
cargo run --bin server

# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/greet?name=Rust&language=fr
curl http://localhost:8080/health
curl http://localhost:8080/languages
```

## Testing

```bash
# Run tests
cargo test

# Run tests with coverage
cargo test --coverage
```

## Documentation

```bash
# Generate documentation
cargo doc --open
```
EOF
            ;;
        "python")
            cat > "$lang_dir/README.md" << 'EOF'
# Python Hello World Example

A comprehensive Hello World implementation in Python with CLI and FastAPI server components.

## Features

- Click-based CLI interface
- FastAPI HTTP server
- Multi-language greeting support
- JSON output format
- Comprehensive test suite with pytest
- API documentation with OpenAPI

## Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Or using virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Usage

### CLI Application

```bash
# Run with default settings
python hello.py

# Custom greeting
python hello.py --name "Python" --language "es"

# JSON output
python hello.py --format json

# List available languages
python hello.py --list-languages
```

### HTTP Server

```bash
# Start the server
python server.py

# Test endpoints
curl http://localhost:8000/
curl http://localhost:8000/greet?name=Python&language=fr
curl http://localhost:8000/health
curl http://localhost:8000/languages
```

## Testing

```bash
# Run tests
pytest

# Run tests with coverage
pytest --cov=hello --cov=server
```

## Documentation

The server provides interactive API documentation at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
EOF
            ;;
        "nodejs")
            cat > "$lang_dir/README.md" << 'EOF'
# Node.js Hello World Example

A comprehensive Hello World implementation in Node.js with CLI and Express server components.

## Features

- Commander.js CLI interface
- Express HTTP server
- Multi-language greeting support
- JSON output format
- Comprehensive test suite with Jest
- API documentation

## Setup

```bash
# Install dependencies
npm install

# Or using yarn
yarn install
```

## Usage

### CLI Application

```bash
# Run with default settings
node hello.js

# Custom greeting
node hello.js --name "Node.js" --language "es"

# JSON output
node hello.js --format json

# List available languages
node hello.js --list-languages
```

### HTTP Server

```bash
# Start the server
npm start

# Or for development with auto-reload
npm run dev

# Test endpoints
curl http://localhost:8000/
curl http://localhost:8000/greet?name=Node.js&language=fr
curl http://localhost:8000/health
curl http://localhost:8000/languages
```

## Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

## Documentation

```bash
# Generate JSDoc documentation
npm run docs
```

The server provides API documentation at:
- API Docs: http://localhost:8000/api-docs
EOF
            ;;
        "bash")
            cat > "$lang_dir/README.md" << 'EOF'
# Bash Hello World Example

A comprehensive Hello World implementation in Bash with CLI and simple HTTP server components.

## Features

- Full argument parsing and validation
- Simple HTTP server using netcat
- Multi-language greeting support
- JSON output format
- Comprehensive test suite
- Color-coded output

## Usage

### CLI Application

```bash
# Make scripts executable
chmod +x *.sh

# Run with default settings
./hello.sh

# Custom greeting
./hello.sh --name "Bash" --language "es"

# JSON output
./hello.sh --format json

# List available languages
./hello.sh --list-languages
```

### HTTP Server

```bash
# Start the server
./server.sh

# Or on custom port
./server.sh --port 3000

# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/greet?name=Bash&language=fr
curl http://localhost:8080/health
curl http://localhost:8080/languages
```

## Testing

```bash
# Run test suite
./test_hello.sh
```

## Requirements

- Bash 4.0+
- netcat (nc) for server functionality
- curl for testing (optional)
EOF
            ;;
    esac
}

# Function to generate API documentation index
generate_api_index() {
    mkdir -p "$DOCS_DIR/api"
    
    cat > "$DOCS_DIR/api/index.md" << 'EOF'
---
layout: page
title: API Documentation
permalink: /api/
---

# API Documentation

This section contains comprehensive API documentation for all language implementations.

## Available Languages

<div class="grid">
  <div class="card">
    <h3><a href="rust/">Rust</a></h3>
    <p>Cargo-generated documentation with rustdoc</p>
  </div>
  
  <div class="card">
    <h3><a href="python/">Python</a></h3>
    <p>Sphinx-generated documentation with autodoc</p>
  </div>
  
  <div class="card">
    <h3><a href="nodejs/">Node.js</a></h3>
    <p>JSDoc-generated documentation</p>
  </div>
  
  <div class="card">
    <h3><a href="php/">PHP</a></h3>
    <p>phpDocumentor-generated documentation</p>
  </div>
  
  <div class="card">
    <h3><a href="bash/">Bash</a></h3>
    <p>Manual documentation for shell scripts</p>
  </div>
</div>

## Common API Endpoints

All server implementations provide these common endpoints:

### Greeting Endpoints
- `GET /` - Generate greeting with query parameters
- `GET /greet` - Same as root endpoint

**Parameters:**
- `name` (string, optional) - Name to greet (default: "World")
- `language` (string, optional) - Language code (default: "en")

### System Endpoints
- `GET /health` - Health check and system information
- `GET /languages` - List available languages
- `GET /languages/{language}` - Get information about specific language

## Response Format

All endpoints return JSON responses with consistent structure:

```json
{
  "message": "Hello, World!",
  "name": "World",
  "language": "en",
  "timestamp": "2024-01-01T00:00:00Z",
  "server": "Language/Framework"
}
```

## Supported Languages

All implementations support these languages:
- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt)
- Russian (ru)
- Japanese (ja)
- Chinese (zh)
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                GENERATE_API_DOCS=true
                GENERATE_MERMAID=true
                GENERATE_README=true
                INCLUDE_EXAMPLES=true
                shift
                ;;
            --api-only)
                GENERATE_API_DOCS=true
                GENERATE_MERMAID=false
                GENERATE_README=false
                shift
                ;;
            --readme-only)
                GENERATE_API_DOCS=false
                GENERATE_MERMAID=false
                GENERATE_README=true
                shift
                ;;
            --mermaid-only)
                GENERATE_API_DOCS=false
                GENERATE_MERMAID=true
                GENERATE_README=false
                shift
                ;;
            --no-api)
                GENERATE_API_DOCS=false
                shift
                ;;
            --no-mermaid)
                GENERATE_MERMAID=false
                shift
                ;;
            --no-readme)
                GENERATE_README=false
                shift
                ;;
            --no-examples)
                INCLUDE_EXAMPLES=false
                shift
                ;;
            --format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --output)
                DOCS_DIR="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    log "Starting Universal Documentation Generation"
    log "Project root: $PROJECT_ROOT"
    log "Documentation directory: $DOCS_DIR"
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Create output directories
    mkdir -p "$DOCS_DIR"/{api,diagrams,guides}
    
    # Generate documentation based on configuration
    if [[ "$GENERATE_API_DOCS" == true ]]; then
        log "Generating API documentation..."
        generate_api_index
        generate_rust_docs
        generate_python_docs
        generate_nodejs_docs
        generate_php_docs
        generate_bash_docs
    fi
    
    if [[ "$GENERATE_MERMAID" == true ]]; then
        generate_mermaid_diagrams
    fi
    
    if [[ "$GENERATE_README" == true ]]; then
        generate_readme_files
    fi
    
    log_success "Documentation generation completed!"
    log "Documentation available at: $DOCS_DIR"
    
    if [[ -f "$DOCS_DIR/index.md" ]]; then
        log "Main documentation: file://$DOCS_DIR/index.html"
    fi
}

# Parse arguments and run main function
parse_args "$@"
main
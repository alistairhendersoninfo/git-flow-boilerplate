#!/bin/bash
# Universal Git Flow Boilerplate Setup Script
# Initializes new projects with selected language and framework

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Default values
LANGUAGE=""
FRAMEWORK=""
PROJECT_NAME=""
OUTPUT_DIR=""
INIT_GIT=true
SETUP_CI=true
GENERATE_DOCS=true
VERBOSE=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Supported languages and frameworks
declare -A SUPPORTED_LANGUAGES=(
    ["rust"]="actix rocket warp"
    ["python"]="fastapi django flask"
    ["nodejs"]="express koa nestjs"
    ["javascript"]="vanilla react vue"
    ["php"]="slim laravel symfony"
    ["bash"]="cli server"
)

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

log_info() {
    echo -e "${CYAN}[INFO]${NC} $*"
}

# Function to show usage
show_usage() {
    cat << EOF
${PURPLE}Universal Git Flow Boilerplate Setup Script${NC}

${CYAN}Usage:${NC} $0 [OPTIONS]

${CYAN}Required Options:${NC}
    -l, --language LANG     Programming language (rust, python, nodejs, javascript, php, bash)
    -n, --name NAME         Project name

${CYAN}Optional Options:${NC}
    -f, --framework FRAMEWORK   Framework to use (depends on language)
    -o, --output DIR           Output directory (default: ./PROJECT_NAME)
    --no-git                   Skip git initialization
    --no-ci                    Skip CI/CD setup
    --no-docs                  Skip documentation generation
    --verbose                  Verbose output
    --help                     Show this help message

${CYAN}Supported Languages and Frameworks:${NC}
$(for lang in "${!SUPPORTED_LANGUAGES[@]}"; do
    echo "    ${YELLOW}$lang${NC}: ${SUPPORTED_LANGUAGES[$lang]}"
done)

${CYAN}Examples:${NC}
    $0 -l python -f fastapi -n my-api
    $0 -l rust -f actix -n my-service
    $0 -l nodejs -f express -n my-app
    $0 -l javascript -f react -n my-frontend
    $0 -l bash -n my-scripts

${CYAN}What this script does:${NC}
    1. Creates project directory structure
    2. Copies language-specific templates
    3. Initializes git repository with proper .gitignore
    4. Sets up CI/CD workflows
    5. Generates initial documentation
    6. Configures development environment
EOF
}

# Function to validate language
validate_language() {
    local lang="$1"
    if [[ -z "${SUPPORTED_LANGUAGES[$lang]:-}" ]]; then
        log_error "Unsupported language: $lang"
        log_info "Supported languages: ${!SUPPORTED_LANGUAGES[*]}"
        return 1
    fi
    return 0
}

# Function to validate framework
validate_framework() {
    local lang="$1"
    local framework="$2"
    
    if [[ -z "$framework" ]]; then
        return 0  # Framework is optional
    fi
    
    local supported_frameworks="${SUPPORTED_LANGUAGES[$lang]}"
    if [[ ! " $supported_frameworks " =~ " $framework " ]]; then
        log_error "Unsupported framework '$framework' for language '$lang'"
        log_info "Supported frameworks for $lang: $supported_frameworks"
        return 1
    fi
    return 0
}

# Function to create project directory structure
create_project_structure() {
    local project_dir="$1"
    
    log "Creating project directory structure..."
    
    mkdir -p "$project_dir"/{src,tests,docs,scripts,.github/workflows}
    
    # Language-specific directories
    case "$LANGUAGE" in
        "rust")
            mkdir -p "$project_dir"/{src/bin,examples,benches}
            ;;
        "python")
            mkdir -p "$project_dir"/{src,tests,docs,requirements}
            ;;
        "nodejs"|"javascript")
            mkdir -p "$project_dir"/{src,test,public,build}
            ;;
        "php")
            mkdir -p "$project_dir"/{src,tests,public,config}
            ;;
        "bash")
            mkdir -p "$project_dir"/{bin,lib,test}
            ;;
    esac
    
    log_success "Project structure created"
}

# Function to copy template files
copy_template_files() {
    local project_dir="$1"
    local template_dir="$PROJECT_ROOT/templates/$LANGUAGE"
    
    log "Copying template files for $LANGUAGE..."
    
    if [[ ! -d "$template_dir" ]]; then
        log_warning "Template directory not found: $template_dir"
        log_info "Using example files instead..."
        template_dir="$PROJECT_ROOT/examples/$LANGUAGE"
    fi
    
    if [[ -d "$template_dir" ]]; then
        # Copy template files
        cp -r "$template_dir"/* "$project_dir/" 2>/dev/null || true
        
        # Framework-specific customizations
        if [[ -n "$FRAMEWORK" ]]; then
            customize_for_framework "$project_dir"
        fi
        
        log_success "Template files copied"
    else
        log_error "No template or example files found for $LANGUAGE"
        return 1
    fi
}

# Function to customize for specific framework
customize_for_framework() {
    local project_dir="$1"
    
    log "Customizing for framework: $FRAMEWORK"
    
    case "$LANGUAGE-$FRAMEWORK" in
        "python-django")
            # Django-specific setup would go here
            log_info "Django customization not yet implemented"
            ;;
        "nodejs-nestjs")
            # NestJS-specific setup would go here
            log_info "NestJS customization not yet implemented"
            ;;
        "rust-rocket")
            # Rocket-specific setup would go here
            log_info "Rocket customization not yet implemented"
            ;;
        *)
            log_info "Using default configuration for $FRAMEWORK"
            ;;
    esac
}

# Function to initialize git repository
init_git_repo() {
    local project_dir="$1"
    
    if [[ "$INIT_GIT" != true ]]; then
        return 0
    fi
    
    log "Initializing git repository..."
    
    cd "$project_dir"
    
    # Initialize git
    git init
    git branch -m main
    
    # Create .gitignore
    create_gitignore
    
    # Initial commit
    git add .
    git commit -m "Initial commit: $LANGUAGE project with $FRAMEWORK framework

- Project structure created
- Template files added
- CI/CD workflows configured
- Documentation initialized

Generated by Universal Git Flow Boilerplate"
    
    cd "$PROJECT_ROOT"
    log_success "Git repository initialized"
}

# Function to create .gitignore
create_gitignore() {
    cat > .gitignore << 'EOF'
# Universal Git Flow Boilerplate .gitignore

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~
.project
.classpath
.settings/

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov
.nyc_output

# Dependency directories
node_modules/
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Rust
target/
Cargo.lock
**/*.rs.bk

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.pytest_cache/

# PHP
/vendor/
composer.phar
composer.lock
.env
.env.backup
.phpunit.result.cache
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log

# JavaScript/Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.eslintcache
.parcel-cache/
.next
out/
build/
dist/

# React
build/
.env.local
.env.development.local
.env.test.local
.env.production.local

# Vue.js
.DS_Store
node_modules/
dist/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env.local
.env.*.local

# Documentation
docs/_site/
docs/.sass-cache/
docs/.jekyll-cache/
docs/.jekyll-metadata

# Temporary files
*.tmp
*.temp
.cache/
EOF

    # Add language-specific ignores
    case "$LANGUAGE" in
        "rust")
            echo "" >> .gitignore
            echo "# Rust specific" >> .gitignore
            echo "target/" >> .gitignore
            echo "**/*.rs.bk" >> .gitignore
            ;;
        "python")
            echo "" >> .gitignore
            echo "# Python specific" >> .gitignore
            echo "*.pyc" >> .gitignore
            echo ".pytest_cache/" >> .gitignore
            echo ".coverage" >> .gitignore
            ;;
        "nodejs"|"javascript")
            echo "" >> .gitignore
            echo "# Node.js specific" >> .gitignore
            echo "node_modules/" >> .gitignore
            echo "package-lock.json" >> .gitignore
            ;;
        "php")
            echo "" >> .gitignore
            echo "# PHP specific" >> .gitignore
            echo "vendor/" >> .gitignore
            echo "composer.lock" >> .gitignore
            ;;
    esac
}

# Function to setup CI/CD
setup_ci_cd() {
    local project_dir="$1"
    
    if [[ "$SETUP_CI" != true ]]; then
        return 0
    fi
    
    log "Setting up CI/CD workflows..."
    
    # Copy GitHub Actions workflows
    local workflows_source="$PROJECT_ROOT/.github/workflows"
    local workflows_dest="$project_dir/.github/workflows"
    
    if [[ -d "$workflows_source" ]]; then
        cp -r "$workflows_source"/* "$workflows_dest/"
        log_success "CI/CD workflows configured"
    else
        log_warning "CI/CD workflow templates not found"
    fi
}

# Function to generate initial documentation
generate_initial_docs() {
    local project_dir="$1"
    
    if [[ "$GENERATE_DOCS" != true ]]; then
        return 0
    fi
    
    log "Generating initial documentation..."
    
    cd "$project_dir"
    
    # Create README.md
    create_project_readme
    
    # Create CONTRIBUTING.md
    create_contributing_guide
    
    # Create LICENSE
    create_license_file
    
    # Copy documentation scripts
    if [[ -f "$PROJECT_ROOT/scripts/generate-docs.sh" ]]; then
        cp "$PROJECT_ROOT/scripts/generate-docs.sh" scripts/
        chmod +x scripts/generate-docs.sh
    fi
    
    cd "$PROJECT_ROOT"
    log_success "Initial documentation generated"
}

# Function to create project README
create_project_readme() {
    cat > README.md << EOF
# $PROJECT_NAME

A $LANGUAGE project$([ -n "$FRAMEWORK" ] && echo " using $FRAMEWORK framework") generated with Universal Git Flow Boilerplate.

## 🚀 Quick Start

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd $PROJECT_NAME

# Install dependencies
$(get_install_command)

# Run the application
$(get_run_command)

# Run tests
$(get_test_command)
\`\`\`

## 📋 Features

- **Modern $LANGUAGE Development**: Latest language features and best practices
$([ -n "$FRAMEWORK" ] && echo "- **$FRAMEWORK Framework**: Production-ready web framework")
- **Comprehensive Testing**: Unit and integration tests
- **CI/CD Pipeline**: Automated testing and deployment
- **Documentation**: Auto-generated API documentation
- **Code Quality**: Linting, formatting, and static analysis

## 🏗️ Project Structure

\`\`\`
$PROJECT_NAME/
├── src/                    # Source code
├── tests/                  # Test files
├── docs/                   # Documentation
├── scripts/                # Build and utility scripts
├── .github/workflows/      # CI/CD pipelines
└── README.md              # This file
\`\`\`

## 🛠️ Development

### Prerequisites

$(get_prerequisites)

### Setup

\`\`\`bash
# Install dependencies
$(get_install_command)

# Run in development mode
$(get_dev_command)
\`\`\`

### Testing

\`\`\`bash
# Run all tests
$(get_test_command)

# Run tests with coverage
$(get_coverage_command)
\`\`\`

### Building

\`\`\`bash
# Build for production
$(get_build_command)
\`\`\`

## 📚 Documentation

- [API Documentation](docs/api/)
- [Development Guide](docs/development.md)
- [Deployment Guide](docs/deployment.md)

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Generated with [Universal Git Flow Boilerplate](https://github.com/your-username/git-flow-boilerplate)
- Built with $LANGUAGE$([ -n "$FRAMEWORK" ] && echo " and $FRAMEWORK")
EOF
}

# Function to get install command based on language
get_install_command() {
    case "$LANGUAGE" in
        "rust") echo "cargo build" ;;
        "python") echo "pip install -r requirements.txt" ;;
        "nodejs"|"javascript") echo "npm install" ;;
        "php") echo "composer install" ;;
        "bash") echo "chmod +x scripts/*.sh" ;;
        *) echo "# See language-specific documentation" ;;
    esac
}

# Function to get run command based on language
get_run_command() {
    case "$LANGUAGE" in
        "rust") echo "cargo run" ;;
        "python") echo "python src/main.py" ;;
        "nodejs") echo "npm start" ;;
        "javascript") echo "npm run dev" ;;
        "php") echo "php -S localhost:8000 public/index.php" ;;
        "bash") echo "./scripts/run.sh" ;;
        *) echo "# See language-specific documentation" ;;
    esac
}

# Function to get test command based on language
get_test_command() {
    case "$LANGUAGE" in
        "rust") echo "cargo test" ;;
        "python") echo "pytest" ;;
        "nodejs"|"javascript") echo "npm test" ;;
        "php") echo "vendor/bin/phpunit" ;;
        "bash") echo "./test/run_tests.sh" ;;
        *) echo "# See language-specific documentation" ;;
    esac
}

# Function to get dev command based on language
get_dev_command() {
    case "$LANGUAGE" in
        "rust") echo "cargo run --bin dev" ;;
        "python") echo "python src/main.py --dev" ;;
        "nodejs"|"javascript") echo "npm run dev" ;;
        "php") echo "php -S localhost:8000 -t public/" ;;
        "bash") echo "./scripts/dev.sh" ;;
        *) echo "# See language-specific documentation" ;;
    esac
}

# Function to get coverage command based on language
get_coverage_command() {
    case "$LANGUAGE" in
        "rust") echo "cargo tarpaulin" ;;
        "python") echo "pytest --cov" ;;
        "nodejs"|"javascript") echo "npm run test:coverage" ;;
        "php") echo "vendor/bin/phpunit --coverage-html coverage" ;;
        "bash") echo "./test/run_tests.sh --coverage" ;;
        *) echo "# See language-specific documentation" ;;
    esac
}

# Function to get build command based on language
get_build_command() {
    case "$LANGUAGE" in
        "rust") echo "cargo build --release" ;;
        "python") echo "python setup.py build" ;;
        "nodejs"|"javascript") echo "npm run build" ;;
        "php") echo "composer install --no-dev --optimize-autoloader" ;;
        "bash") echo "./scripts/build.sh" ;;
        *) echo "# See language-specific documentation" ;;
    esac
}

# Function to get prerequisites based on language
get_prerequisites() {
    case "$LANGUAGE" in
        "rust") echo "- Rust 1.70+ and Cargo" ;;
        "python") echo "- Python 3.8+ and pip" ;;
        "nodejs"|"javascript") echo "- Node.js 16+ and npm" ;;
        "php") echo "- PHP 7.4+ and Composer" ;;
        "bash") echo "- Bash 4.0+ and common Unix tools" ;;
        *) echo "- See language-specific requirements" ;;
    esac
}

# Function to create contributing guide
create_contributing_guide() {
    cat > CONTRIBUTING.md << 'EOF'
# Contributing Guide

Thank you for your interest in contributing to this project!

## Development Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Add tests for your changes
5. Ensure all tests pass
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to the branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

## Code Standards

- Follow the existing code style
- Write tests for new functionality
- Update documentation as needed
- Ensure CI/CD pipeline passes

## Reporting Issues

- Use the issue tracker to report bugs
- Include steps to reproduce the issue
- Provide relevant system information

## Questions?

Feel free to open an issue for questions about contributing.
EOF
}

# Function to create license file
create_license_file() {
    cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2024 Project Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
}

# Function to show project summary
show_project_summary() {
    local project_dir="$1"
    
    echo
    echo -e "${GREEN}🎉 Project created successfully!${NC}"
    echo
    echo -e "${CYAN}Project Details:${NC}"
    echo -e "  ${YELLOW}Name:${NC} $PROJECT_NAME"
    echo -e "  ${YELLOW}Language:${NC} $LANGUAGE"
    echo -e "  ${YELLOW}Framework:${NC} ${FRAMEWORK:-"Default"}"
    echo -e "  ${YELLOW}Location:${NC} $project_dir"
    echo
    echo -e "${CYAN}Next Steps:${NC}"
    echo -e "  1. ${BLUE}cd $project_dir${NC}"
    echo -e "  2. $(get_install_command)"
    echo -e "  3. $(get_run_command)"
    echo
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "  ${YELLOW}Development:${NC} $(get_dev_command)"
    echo -e "  ${YELLOW}Testing:${NC} $(get_test_command)"
    echo -e "  ${YELLOW}Building:${NC} $(get_build_command)"
    echo -e "  ${YELLOW}Documentation:${NC} ./scripts/generate-docs.sh"
    echo
    echo -e "${GREEN}Happy coding! 🚀${NC}"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l|--language)
                LANGUAGE="$2"
                shift 2
                ;;
            -f|--framework)
                FRAMEWORK="$2"
                shift 2
                ;;
            -n|--name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --no-git)
                INIT_GIT=false
                shift
                ;;
            --no-ci)
                SETUP_CI=false
                shift
                ;;
            --no-docs)
                GENERATE_DOCS=false
                shift
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
    log "Starting Universal Git Flow Boilerplate Setup"
    
    # Validate required arguments
    if [[ -z "$LANGUAGE" ]]; then
        log_error "Language is required. Use -l or --language option."
        show_usage
        exit 1
    fi
    
    if [[ -z "$PROJECT_NAME" ]]; then
        log_error "Project name is required. Use -n or --name option."
        show_usage
        exit 1
    fi
    
    # Validate language and framework
    if ! validate_language "$LANGUAGE"; then
        exit 1
    fi
    
    if ! validate_framework "$LANGUAGE" "$FRAMEWORK"; then
        exit 1
    fi
    
    # Set output directory
    if [[ -z "$OUTPUT_DIR" ]]; then
        OUTPUT_DIR="./$PROJECT_NAME"
    fi
    
    # Check if output directory already exists
    if [[ -d "$OUTPUT_DIR" ]]; then
        log_error "Directory already exists: $OUTPUT_DIR"
        read -p "Do you want to continue and overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled"
            exit 0
        fi
        rm -rf "$OUTPUT_DIR"
    fi
    
    # Create project
    create_project_structure "$OUTPUT_DIR"
    copy_template_files "$OUTPUT_DIR"
    init_git_repo "$OUTPUT_DIR"
    setup_ci_cd "$OUTPUT_DIR"
    generate_initial_docs "$OUTPUT_DIR"
    
    # Show summary
    show_project_summary "$OUTPUT_DIR"
}

# Parse arguments and run main function
parse_args "$@"
main
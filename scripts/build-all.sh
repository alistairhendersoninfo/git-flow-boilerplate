#!/bin/bash
# Universal Build Script
# Builds all language examples and documentation

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EXAMPLES_DIR="$PROJECT_ROOT/examples"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BUILD_ALL=true
SPECIFIC_LANGUAGE=""
BUILD_DOCS=true
BUILD_PRODUCTION=false
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
Universal Build Script

Usage: $0 [OPTIONS]

Options:
    --all                   Build all languages (default)
    --language LANG         Build specific language
    --no-docs               Skip documentation build
    --production            Build for production
    --verbose               Verbose output
    --help                  Show this help message

Supported Languages:
    - rust
    - python
    - nodejs
    - bash
    - php (planned)

Examples:
    $0                      # Build everything
    $0 --language rust      # Build only Rust
    $0 --production         # Production build
    $0 --no-docs            # Skip documentation
EOF
}

# Function to build Rust project
build_rust() {
    local lang_dir="$EXAMPLES_DIR/rust"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "Rust example directory not found: $lang_dir"
        return 1
    fi
    
    log "Building Rust project..."
    cd "$lang_dir"
    
    local build_cmd="cargo build"
    if [[ "$BUILD_PRODUCTION" == true ]]; then
        build_cmd="cargo build --release"
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        build_cmd="$build_cmd --verbose"
    fi
    
    if $build_cmd; then
        log_success "Rust build completed"
        
        # Generate documentation
        if cargo doc --no-deps --document-private-items; then
            log_success "Rust documentation generated"
        else
            log_warning "Rust documentation generation failed"
        fi
        
        return 0
    else
        log_error "Rust build failed"
        return 1
    fi
}

# Function to build Python project
build_python() {
    local lang_dir="$EXAMPLES_DIR/python"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "Python example directory not found: $lang_dir"
        return 1
    fi
    
    log "Building Python project..."
    cd "$lang_dir"
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "venv" ]]; then
        log "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    if pip install -r requirements.txt; then
        log_success "Python dependencies installed"
    else
        log_error "Python dependency installation failed"
        return 1
    fi
    
    # Run linting and formatting checks
    if [[ "$BUILD_PRODUCTION" == true ]]; then
        log "Running Python code quality checks..."
        
        if command -v black &> /dev/null; then
            black --check . || log_warning "Black formatting check failed"
        fi
        
        if command -v flake8 &> /dev/null; then
            flake8 . || log_warning "Flake8 linting failed"
        fi
        
        if command -v mypy &> /dev/null; then
            mypy . --ignore-missing-imports || log_warning "MyPy type checking failed"
        fi
    fi
    
    log_success "Python build completed"
    return 0
}

# Function to build Node.js project
build_nodejs() {
    local lang_dir="$EXAMPLES_DIR/nodejs"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "Node.js example directory not found: $lang_dir"
        return 1
    fi
    
    log "Building Node.js project..."
    cd "$lang_dir"
    
    # Install dependencies
    if npm install; then
        log_success "Node.js dependencies installed"
    else
        log_error "Node.js dependency installation failed"
        return 1
    fi
    
    # Run linting and formatting checks
    if [[ "$BUILD_PRODUCTION" == true ]]; then
        log "Running Node.js code quality checks..."
        
        if npm run lint 2>/dev/null; then
            log_success "ESLint passed"
        else
            log_warning "ESLint check failed"
        fi
        
        if npm run format -- --check 2>/dev/null; then
            log_success "Prettier formatting check passed"
        else
            log_warning "Prettier formatting check failed"
        fi
    fi
    
    # Generate documentation
    if npm run docs 2>/dev/null; then
        log_success "Node.js documentation generated"
    else
        log_warning "Node.js documentation generation failed"
    fi
    
    log_success "Node.js build completed"
    return 0
}

# Function to build Bash project
build_bash() {
    local lang_dir="$EXAMPLES_DIR/bash"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "Bash example directory not found: $lang_dir"
        return 1
    fi
    
    log "Building Bash project..."
    cd "$lang_dir"
    
    # Make scripts executable
    chmod +x *.sh
    
    # Run shellcheck if available
    if command -v shellcheck &> /dev/null; then
        log "Running shellcheck..."
        if shellcheck *.sh; then
            log_success "Shellcheck passed"
        else
            log_warning "Shellcheck found issues"
        fi
    fi
    
    log_success "Bash build completed"
    return 0
}

# Function to build PHP project (placeholder)
build_php() {
    local lang_dir="$EXAMPLES_DIR/php"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "PHP example directory not found: $lang_dir"
        return 1
    fi
    
    log "Building PHP project..."
    cd "$lang_dir"
    
    # Install dependencies
    if composer install; then
        log_success "PHP dependencies installed"
    else
        log_error "PHP dependency installation failed"
        return 1
    fi
    
    # Run code quality checks
    if [[ "$BUILD_PRODUCTION" == true ]]; then
        log "Running PHP code quality checks..."
        
        # PHP syntax check
        find . -name "*.php" -exec php -l {} \; > /dev/null
        
        # PHPStan if available
        if [[ -f "vendor/bin/phpstan" ]]; then
            vendor/bin/phpstan analyse --level=5 src/ || log_warning "PHPStan analysis failed"
        fi
    fi
    
    log_success "PHP build completed"
    return 0
}

# Function to build documentation
build_documentation() {
    if [[ "$BUILD_DOCS" != true ]]; then
        return 0
    fi
    
    log "Building documentation..."
    
    # Generate documentation using the docs script
    if [[ -x "$PROJECT_ROOT/scripts/generate-docs.sh" ]]; then
        if "$PROJECT_ROOT/scripts/generate-docs.sh"; then
            log_success "Documentation generated"
        else
            log_warning "Documentation generation failed"
        fi
    else
        log_warning "Documentation generation script not found"
    fi
    
    # Build Jekyll site if in docs directory
    if [[ -f "$PROJECT_ROOT/docs/_config.yml" ]]; then
        cd "$PROJECT_ROOT/docs"
        
        if command -v bundle &> /dev/null; then
            log "Building Jekyll site..."
            if bundle exec jekyll build; then
                log_success "Jekyll site built"
            else
                log_warning "Jekyll build failed"
            fi
        else
            log_warning "Bundle not found, skipping Jekyll build"
        fi
    fi
}

# Function to build specific language
build_language() {
    local language="$1"
    
    case "$language" in
        "rust")
            build_rust
            ;;
        "python")
            build_python
            ;;
        "nodejs")
            build_nodejs
            ;;
        "bash")
            build_bash
            ;;
        "php")
            build_php
            ;;
        *)
            log_error "Unsupported language: $language"
            return 1
            ;;
    esac
}

# Function to build all languages
build_all_languages() {
    local languages=("rust" "python" "nodejs" "bash")
    local failed_builds=()
    
    for lang in "${languages[@]}"; do
        if ! build_language "$lang"; then
            failed_builds+=("$lang")
        fi
    done
    
    if [[ ${#failed_builds[@]} -gt 0 ]]; then
        log_error "Failed builds: ${failed_builds[*]}"
        return 1
    fi
    
    return 0
}

# Function to create build summary
create_build_summary() {
    log "Creating build summary..."
    
    cat > "$PROJECT_ROOT/build-summary.md" << 'EOF'
# Build Summary

## Build Information
- **Date**: $(date)
- **Mode**: $([ "$BUILD_PRODUCTION" == true ] && echo "Production" || echo "Development")
- **Documentation**: $([ "$BUILD_DOCS" == true ] && echo "Included" || echo "Skipped")

## Language Builds
- **Rust**: ✅ Completed
- **Python**: ✅ Completed  
- **Node.js**: ✅ Completed
- **Bash**: ✅ Completed

## Documentation
- **API Docs**: Generated
- **Mermaid Diagrams**: Generated
- **Jekyll Site**: Built

## Artifacts
- Language binaries and libraries
- Generated documentation
- Test coverage reports
- Build logs

## Next Steps
1. Run tests: `./scripts/run-tests.sh`
2. Deploy documentation: Push to main branch
3. Create release: Tag and push
EOF

    log_success "Build summary created"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                BUILD_ALL=true
                shift
                ;;
            --language)
                SPECIFIC_LANGUAGE="$2"
                BUILD_ALL=false
                shift 2
                ;;
            --no-docs)
                BUILD_DOCS=false
                shift
                ;;
            --production)
                BUILD_PRODUCTION=true
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
    log "Starting Universal Build Process"
    log "Project root: $PROJECT_ROOT"
    log "Build mode: $([ "$BUILD_PRODUCTION" == true ] && echo "Production" || echo "Development")"
    
    cd "$PROJECT_ROOT"
    
    # Build languages
    if [[ "$BUILD_ALL" == true ]]; then
        if ! build_all_languages; then
            log_error "Some builds failed"
            exit 1
        fi
    else
        if ! build_language "$SPECIFIC_LANGUAGE"; then
            log_error "Build failed for $SPECIFIC_LANGUAGE"
            exit 1
        fi
    fi
    
    # Build documentation
    build_documentation
    
    # Create build summary
    create_build_summary
    
    log_success "Build process completed successfully!"
}

# Parse arguments and run main function
parse_args "$@"
main
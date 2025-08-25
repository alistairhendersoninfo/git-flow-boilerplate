#!/bin/bash
# Universal Test Runner Script
# Runs tests across all supported languages

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
RUN_ALL=true
SPECIFIC_LANGUAGE=""
WITH_COVERAGE=false
TEST_TYPE="all"
VERBOSE=false
PARALLEL=false

# Test results tracking
declare -A TEST_RESULTS
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

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
Universal Test Runner Script

Usage: $0 [OPTIONS]

Options:
    --all                   Run tests for all languages (default)
    --language LANG         Run tests for specific language
    --coverage              Run tests with coverage reporting
    --type TYPE             Test type: unit, integration, e2e, all (default: all)
    --parallel              Run tests in parallel
    --verbose               Verbose output
    --help                  Show this help message

Supported Languages:
    - rust
    - python
    - nodejs
    - bash
    - php (planned)
    - javascript (planned)
    - react (planned)
    - vue (planned)

Examples:
    $0                      # Run all tests
    $0 --language python    # Run only Python tests
    $0 --coverage           # Run all tests with coverage
    $0 --type unit          # Run only unit tests
    $0 --parallel           # Run tests in parallel
EOF
}

# Function to run Rust tests
run_rust_tests() {
    local lang_dir="$EXAMPLES_DIR/rust"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "Rust example directory not found: $lang_dir"
        return 1
    fi
    
    log "Running Rust tests..."
    cd "$lang_dir"
    
    local test_cmd="cargo test"
    if [[ "$WITH_COVERAGE" == true ]]; then
        if command -v cargo-tarpaulin &> /dev/null; then
            test_cmd="cargo tarpaulin --out xml"
        else
            log_warning "cargo-tarpaulin not found, running tests without coverage"
        fi
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        test_cmd="$test_cmd --verbose"
    fi
    
    if $test_cmd; then
        TEST_RESULTS["rust"]="PASS"
        log_success "Rust tests passed"
        return 0
    else
        TEST_RESULTS["rust"]="FAIL"
        log_error "Rust tests failed"
        return 1
    fi
}

# Function to run Python tests
run_python_tests() {
    local lang_dir="$EXAMPLES_DIR/python"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "Python example directory not found: $lang_dir"
        return 1
    fi
    
    log "Running Python tests..."
    cd "$lang_dir"
    
    # Check if virtual environment exists
    if [[ -d "venv" ]]; then
        source venv/bin/activate
    fi
    
    local test_cmd="pytest"
    if [[ "$WITH_COVERAGE" == true ]]; then
        test_cmd="pytest --cov=hello --cov=server --cov-report=xml --cov-report=html"
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        test_cmd="$test_cmd -v"
    fi
    
    if $test_cmd; then
        TEST_RESULTS["python"]="PASS"
        log_success "Python tests passed"
        return 0
    else
        TEST_RESULTS["python"]="FAIL"
        log_error "Python tests failed"
        return 1
    fi
}

# Function to run Node.js tests
run_nodejs_tests() {
    local lang_dir="$EXAMPLES_DIR/nodejs"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "Node.js example directory not found: $lang_dir"
        return 1
    fi
    
    log "Running Node.js tests..."
    cd "$lang_dir"
    
    # Install dependencies if needed
    if [[ ! -d "node_modules" ]]; then
        log "Installing Node.js dependencies..."
        npm install
    fi
    
    local test_cmd="npm test"
    if [[ "$WITH_COVERAGE" == true ]]; then
        test_cmd="npm run test:coverage"
    fi
    
    if $test_cmd; then
        TEST_RESULTS["nodejs"]="PASS"
        log_success "Node.js tests passed"
        return 0
    else
        TEST_RESULTS["nodejs"]="FAIL"
        log_error "Node.js tests failed"
        return 1
    fi
}

# Function to run Bash tests
run_bash_tests() {
    local lang_dir="$EXAMPLES_DIR/bash"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "Bash example directory not found: $lang_dir"
        return 1
    fi
    
    log "Running Bash tests..."
    cd "$lang_dir"
    
    # Make scripts executable
    chmod +x *.sh
    
    if ./test_hello.sh; then
        TEST_RESULTS["bash"]="PASS"
        log_success "Bash tests passed"
        return 0
    else
        TEST_RESULTS["bash"]="FAIL"
        log_error "Bash tests failed"
        return 1
    fi
}

# Function to run PHP tests (placeholder)
run_php_tests() {
    local lang_dir="$EXAMPLES_DIR/php"
    
    if [[ ! -d "$lang_dir" ]]; then
        log_warning "PHP example directory not found: $lang_dir"
        return 1
    fi
    
    log "Running PHP tests..."
    cd "$lang_dir"
    
    # Install dependencies if needed
    if [[ ! -d "vendor" ]]; then
        log "Installing PHP dependencies..."
        composer install
    fi
    
    local test_cmd="vendor/bin/phpunit"
    if [[ "$WITH_COVERAGE" == true ]]; then
        test_cmd="vendor/bin/phpunit --coverage-html coverage --coverage-clover coverage.xml"
    fi
    
    if $test_cmd; then
        TEST_RESULTS["php"]="PASS"
        log_success "PHP tests passed"
        return 0
    else
        TEST_RESULTS["php"]="FAIL"
        log_error "PHP tests failed"
        return 1
    fi
}

# Function to run tests for a specific language
run_language_tests() {
    local language="$1"
    
    case "$language" in
        "rust")
            run_rust_tests
            ;;
        "python")
            run_python_tests
            ;;
        "nodejs")
            run_nodejs_tests
            ;;
        "bash")
            run_bash_tests
            ;;
        "php")
            run_php_tests
            ;;
        *)
            log_error "Unsupported language: $language"
            return 1
            ;;
    esac
}

# Function to run all tests
run_all_tests() {
    local languages=("rust" "python" "nodejs" "bash")
    
    if [[ "$PARALLEL" == true ]]; then
        log "Running tests in parallel..."
        local pids=()
        
        for lang in "${languages[@]}"; do
            (run_language_tests "$lang") &
            pids+=($!)
        done
        
        # Wait for all background processes
        for pid in "${pids[@]}"; do
            wait "$pid"
        done
    else
        log "Running tests sequentially..."
        for lang in "${languages[@]}"; do
            run_language_tests "$lang"
            ((TOTAL_TESTS++))
        done
    fi
}

# Function to generate test report
generate_test_report() {
    echo
    echo "========================================"
    echo -e "${BLUE}Test Results Summary${NC}"
    echo "========================================"
    
    for lang in "${!TEST_RESULTS[@]}"; do
        local result="${TEST_RESULTS[$lang]}"
        if [[ "$result" == "PASS" ]]; then
            echo -e "${GREEN}✓ $lang: PASSED${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}✗ $lang: FAILED${NC}"
            ((FAILED_TESTS++))
        fi
    done
    
    echo "========================================"
    echo "Total: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    else
        echo -e "${GREEN}Failed: $FAILED_TESTS${NC}"
    fi
    echo "========================================"
    
    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    fi
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for language-specific tools
    if [[ "$RUN_ALL" == true ]] || [[ "$SPECIFIC_LANGUAGE" == "rust" ]]; then
        if ! command -v cargo &> /dev/null; then
            missing_deps+=("cargo (Rust)")
        fi
    fi
    
    if [[ "$RUN_ALL" == true ]] || [[ "$SPECIFIC_LANGUAGE" == "python" ]]; then
        if ! command -v python3 &> /dev/null; then
            missing_deps+=("python3")
        fi
        if ! command -v pytest &> /dev/null && ! python3 -c "import pytest" 2>/dev/null; then
            missing_deps+=("pytest")
        fi
    fi
    
    if [[ "$RUN_ALL" == true ]] || [[ "$SPECIFIC_LANGUAGE" == "nodejs" ]]; then
        if ! command -v node &> /dev/null; then
            missing_deps+=("node")
        fi
        if ! command -v npm &> /dev/null; then
            missing_deps+=("npm")
        fi
    fi
    
    if [[ "$RUN_ALL" == true ]] || [[ "$SPECIFIC_LANGUAGE" == "php" ]]; then
        if ! command -v php &> /dev/null; then
            missing_deps+=("php")
        fi
        if ! command -v composer &> /dev/null; then
            missing_deps+=("composer")
        fi
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Please install the missing dependencies and try again"
        return 1
    fi
    
    return 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                RUN_ALL=true
                shift
                ;;
            --language)
                SPECIFIC_LANGUAGE="$2"
                RUN_ALL=false
                shift 2
                ;;
            --coverage)
                WITH_COVERAGE=true
                shift
                ;;
            --type)
                TEST_TYPE="$2"
                shift 2
                ;;
            --parallel)
                PARALLEL=true
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
    log "Starting Universal Test Runner"
    log "Project root: $PROJECT_ROOT"
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Run tests
    cd "$PROJECT_ROOT"
    
    if [[ "$RUN_ALL" == true ]]; then
        run_all_tests
    else
        run_language_tests "$SPECIFIC_LANGUAGE"
        ((TOTAL_TESTS++))
    fi
    
    # Generate report
    generate_test_report
}

# Parse arguments and run main function
parse_args "$@"
main
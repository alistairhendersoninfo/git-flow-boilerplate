#!/bin/bash
# Test suite for Hello World Bash application

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELLO_SCRIPT="$SCRIPT_DIR/hello.sh"
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test framework functions
test_start() {
    echo -e "${BLUE}Running test: $1${NC}"
    ((TOTAL_TESTS++))
}

test_pass() {
    echo -e "${GREEN}✓ PASS: $1${NC}"
    ((PASSED_TESTS++))
}

test_fail() {
    echo -e "${RED}✗ FAIL: $1${NC}"
    echo -e "${RED}  Expected: $2${NC}"
    echo -e "${RED}  Got:      $3${NC}"
    ((FAILED_TESTS++))
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    if [[ "$expected" == "$actual" ]]; then
        test_pass "$test_name"
    else
        test_fail "$test_name" "$expected" "$actual"
    fi
}

assert_contains() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    if [[ "$actual" == *"$expected"* ]]; then
        test_pass "$test_name"
    else
        test_fail "$test_name" "String containing '$expected'" "$actual"
    fi
}

assert_json_valid() {
    local json="$1"
    local test_name="$2"
    
    if echo "$json" | python3 -m json.tool > /dev/null 2>&1; then
        test_pass "$test_name"
    else
        test_fail "$test_name" "Valid JSON" "$json"
    fi
}

# Test cases
test_default_greeting() {
    test_start "Default greeting"
    local output
    output=$("$HELLO_SCRIPT")
    assert_contains "Hello, World!" "$output" "Default greeting contains 'Hello, World!'"
}

test_custom_name() {
    test_start "Custom name greeting"
    local output
    output=$("$HELLO_SCRIPT" --name "Bash")
    assert_contains "Hello, Bash!" "$output" "Custom name greeting"
}

test_spanish_greeting() {
    test_start "Spanish greeting"
    local output
    output=$("$HELLO_SCRIPT" --name "Bash" --language "es")
    assert_contains "¡Hola, Bash!" "$output" "Spanish greeting"
}

test_french_greeting() {
    test_start "French greeting"
    local output
    output=$("$HELLO_SCRIPT" --name "Bash" --language "fr")
    assert_contains "Bonjour, Bash!" "$output" "French greeting"
}

test_invalid_language_fallback() {
    test_start "Invalid language fallback"
    local output
    output=$("$HELLO_SCRIPT" --name "Bash" --language "invalid" 2>/dev/null)
    assert_contains "Hello, Bash!" "$output" "Invalid language falls back to English"
}

test_json_output() {
    test_start "JSON output format"
    local output
    output=$("$HELLO_SCRIPT" --name "Bash" --format "json")
    assert_json_valid "$output" "JSON output is valid"
    assert_contains "\"message\":" "$output" "JSON contains message field"
    assert_contains "\"name\": \"Bash\"" "$output" "JSON contains name field"
    assert_contains "\"language\": \"en\"" "$output" "JSON contains language field"
}

test_json_spanish_output() {
    test_start "JSON Spanish output"
    local output
    output=$("$HELLO_SCRIPT" --name "Bash" --language "es" --format "json")
    assert_json_valid "$output" "JSON Spanish output is valid"
    assert_contains "¡Hola, Bash!" "$output" "JSON contains Spanish greeting"
    assert_contains "\"language\": \"es\"" "$output" "JSON contains Spanish language code"
}

test_list_languages_text() {
    test_start "List languages (text format)"
    local output
    output=$("$HELLO_SCRIPT" --list-languages)
    assert_contains "Available languages:" "$output" "Text format shows header"
    assert_contains "en" "$output" "Text format includes English"
    assert_contains "es" "$output" "Text format includes Spanish"
}

test_list_languages_json() {
    test_start "List languages (JSON format)"
    local output
    output=$("$HELLO_SCRIPT" --list-languages --format "json")
    assert_json_valid "$output" "Languages JSON is valid"
    assert_contains "\"languages\":" "$output" "JSON contains languages array"
    assert_contains "\"en\"" "$output" "JSON includes English"
    assert_contains "\"es\"" "$output" "JSON includes Spanish"
}

test_help_option() {
    test_start "Help option"
    local output
    output=$("$HELLO_SCRIPT" --help)
    assert_contains "Usage:" "$output" "Help shows usage"
    assert_contains "Options:" "$output" "Help shows options"
    assert_contains "Examples:" "$output" "Help shows examples"
}

test_version_option() {
    test_start "Version option"
    local output
    output=$("$HELLO_SCRIPT" --version)
    assert_contains "hello.sh" "$output" "Version shows script name"
    assert_contains "1.0.0" "$output" "Version shows version number"
}

test_invalid_format() {
    test_start "Invalid format handling"
    local exit_code=0
    "$HELLO_SCRIPT" --format "invalid" 2>/dev/null || exit_code=$?
    if [[ $exit_code -eq 1 ]]; then
        test_pass "Invalid format exits with error code 1"
    else
        test_fail "Invalid format exits with error code 1" "Exit code 1" "Exit code $exit_code"
    fi
}

# Function to run all tests
run_all_tests() {
    echo -e "${BLUE}Starting Hello World Bash Test Suite${NC}"
    echo "========================================"
    echo
    
    # Check if hello.sh exists and is executable
    if [[ ! -f "$HELLO_SCRIPT" ]]; then
        echo -e "${RED}Error: $HELLO_SCRIPT not found${NC}"
        exit 1
    fi
    
    if [[ ! -x "$HELLO_SCRIPT" ]]; then
        echo -e "${YELLOW}Making $HELLO_SCRIPT executable${NC}"
        chmod +x "$HELLO_SCRIPT"
    fi
    
    # Run all tests
    test_default_greeting
    test_custom_name
    test_spanish_greeting
    test_french_greeting
    test_invalid_language_fallback
    test_json_output
    test_json_spanish_output
    test_list_languages_text
    test_list_languages_json
    test_help_option
    test_version_option
    test_invalid_format
    
    # Print summary
    echo
    echo "========================================"
    echo -e "${BLUE}Test Summary${NC}"
    echo "Total tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${RED}Failed: $FAILED_TESTS${NC}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

# Make hello.sh executable if it isn't already
chmod +x "$HELLO_SCRIPT"

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi
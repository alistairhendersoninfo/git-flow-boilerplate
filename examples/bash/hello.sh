#!/bin/bash
# Hello World application in Bash
# Demonstrates CLI parsing, JSON output, and internationalization

set -euo pipefail

# Default values
NAME="World"
FORMAT="text"
LANGUAGE="en"
LIST_LANGUAGES=false

# Script metadata
SCRIPT_NAME="$(basename "$0")"
SCRIPT_VERSION="1.0.0"
SCRIPT_DESCRIPTION="Hello World CLI application in Bash"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Greeting templates
declare -A GREETINGS=(
    ["en"]="Hello, {}!"
    ["es"]="¡Hola, {}!"
    ["fr"]="Bonjour, {}!"
    ["de"]="Hallo, {}!"
    ["it"]="Ciao, {}!"
    ["pt"]="Olá, {}!"
    ["ru"]="Привет, {}!"
    ["ja"]="こんにちは、{}！"
    ["zh"]="你好，{}！"
)

# Function to show usage
show_usage() {
    cat << EOF
${SCRIPT_DESCRIPTION}

Usage: ${SCRIPT_NAME} [OPTIONS]

Options:
    -n, --name NAME         Name to greet (default: World)
    -f, --format FORMAT     Output format: text, json (default: text)
    -l, --language LANG     Language code (default: en)
    --list-languages        List available languages
    -h, --help             Show this help message
    -v, --version          Show version information

Examples:
    ${SCRIPT_NAME}                          # Hello, World!
    ${SCRIPT_NAME} -n "Bash"                # Hello, Bash!
    ${SCRIPT_NAME} -n "Bash" -l es          # ¡Hola, Bash!
    ${SCRIPT_NAME} -f json                  # JSON output
    ${SCRIPT_NAME} --list-languages         # List available languages

Supported languages: ${!GREETINGS[*]}
EOF
}

# Function to show version
show_version() {
    echo "${SCRIPT_NAME} ${SCRIPT_VERSION}"
}

# Function to get current timestamp in ISO format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Function to list available languages
list_languages() {
    if [[ "$FORMAT" == "json" ]]; then
        local languages_json="["
        local first=true
        for lang in "${!GREETINGS[@]}"; do
            if [[ "$first" == true ]]; then
                first=false
            else
                languages_json+=","
            fi
            languages_json+="\"$lang\""
        done
        languages_json+="]"
        
        cat << EOF
{
  "languages": $languages_json
}
EOF
    else
        echo -e "${BLUE}Available languages:${NC}"
        for lang in "${!GREETINGS[@]}"; do
            echo "  $lang"
        done | sort
    fi
}

# Function to generate greeting
generate_greeting() {
    local name="$1"
    local language="$2"
    
    # Get greeting template, fallback to English if not found
    local template="${GREETINGS[$language]:-${GREETINGS[en]}}"
    
    # Replace placeholder with name
    echo "${template//\{\}/$name}"
}

# Function to output greeting in specified format
output_greeting() {
    local name="$1"
    local language="$2"
    local format="$3"
    
    local message
    message=$(generate_greeting "$name" "$language")
    
    if [[ "$format" == "json" ]]; then
        cat << EOF
{
  "message": "$message",
  "name": "$name",
  "language": "$language",
  "timestamp": "$(get_timestamp)",
  "server": "Bash/Shell"
}
EOF
    else
        echo -e "${GREEN}$message${NC}"
    fi
}

# Function to validate language
validate_language() {
    local lang="$1"
    if [[ -z "${GREETINGS[$lang]:-}" ]]; then
        echo -e "${YELLOW}Warning: Language '$lang' not supported, using English${NC}" >&2
        return 1
    fi
    return 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                NAME="$2"
                shift 2
                ;;
            -f|--format)
                FORMAT="$2"
                if [[ "$FORMAT" != "text" && "$FORMAT" != "json" ]]; then
                    echo -e "${RED}Error: Invalid format '$FORMAT'. Use 'text' or 'json'${NC}" >&2
                    exit 1
                fi
                shift 2
                ;;
            -l|--language)
                LANGUAGE="$2"
                shift 2
                ;;
            --list-languages)
                LIST_LANGUAGES=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Unknown option '$1'${NC}" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    parse_args "$@"
    
    if [[ "$LIST_LANGUAGES" == true ]]; then
        list_languages
        exit 0
    fi
    
    # Validate language (but continue with English if invalid)
    validate_language "$LANGUAGE" || LANGUAGE="en"
    
    # Generate and output greeting
    output_greeting "$NAME" "$LANGUAGE" "$FORMAT"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
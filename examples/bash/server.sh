#!/bin/bash
# Simple HTTP server in Bash using netcat
# Provides REST API endpoints for greetings

set -euo pipefail

# Configuration
PORT=8080
HOST="127.0.0.1"
SERVER_NAME="Bash/Netcat"
VERSION="1.0.0"

# Source the hello.sh functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/hello.sh"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to log messages
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $*" >&2
}

# Function to parse HTTP request
parse_request() {
    local request_line="$1"
    local method path query
    
    # Extract method and path from request line
    method=$(echo "$request_line" | cut -d' ' -f1)
    path=$(echo "$request_line" | cut -d' ' -f2 | cut -d'?' -f1)
    query=$(echo "$request_line" | cut -d' ' -f2 | cut -d'?' -f2)
    
    # If no query string, set to empty
    if [[ "$query" == "$path" ]]; then
        query=""
    fi
    
    echo "$method|$path|$query"
}

# Function to parse query parameters
parse_query() {
    local query="$1"
    declare -A params
    
    if [[ -n "$query" ]]; then
        IFS='&' read -ra PAIRS <<< "$query"
        for pair in "${PAIRS[@]}"; do
            if [[ "$pair" == *"="* ]]; then
                key=$(echo "$pair" | cut -d'=' -f1)
                value=$(echo "$pair" | cut -d'=' -f2 | sed 's/%20/ /g')
                params["$key"]="$value"
            fi
        done
    fi
    
    # Return as key=value pairs
    for key in "${!params[@]}"; do
        echo "$key=${params[$key]}"
    done
}

# Function to send HTTP response
send_response() {
    local status="$1"
    local content_type="$2"
    local body="$3"
    
    local response="HTTP/1.1 $status\r\n"
    response+="Content-Type: $content_type\r\n"
    response+="Content-Length: ${#body}\r\n"
    response+="Connection: close\r\n"
    response+="Server: $SERVER_NAME\r\n"
    response+="\r\n"
    response+="$body"
    
    echo -e "$response"
}

# Function to handle greeting endpoint
handle_greet() {
    local query="$1"
    local name="World"
    local language="en"
    
    # Parse query parameters
    while IFS= read -r param; do
        if [[ "$param" == name=* ]]; then
            name="${param#name=}"
        elif [[ "$param" == language=* ]]; then
            language="${param#language=}"
        fi
    done <<< "$(parse_query "$query")"
    
    # Generate greeting JSON
    local message
    message=$(generate_greeting "$name" "$language")
    
    local json_response
    json_response=$(cat << EOF
{
  "message": "$message",
  "name": "$name",
  "language": "$language",
  "timestamp": "$(get_timestamp)",
  "server": "$SERVER_NAME"
}
EOF
)
    
    send_response "200 OK" "application/json" "$json_response"
}

# Function to handle health endpoint
handle_health() {
    local json_response
    json_response=$(cat << EOF
{
  "status": "healthy",
  "version": "$VERSION",
  "uptime": "N/A"
}
EOF
)
    
    send_response "200 OK" "application/json" "$json_response"
}

# Function to handle languages endpoint
handle_languages() {
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
    
    send_response "200 OK" "application/json" "$languages_json"
}

# Function to handle 404 errors
handle_404() {
    local json_response='{"error": "Not Found", "message": "The requested endpoint does not exist"}'
    send_response "404 Not Found" "application/json" "$json_response"
}

# Function to handle requests
handle_request() {
    local request_line
    read -r request_line
    
    log "Request: $request_line"
    
    # Parse request
    local parsed
    parsed=$(parse_request "$request_line")
    local method path query
    IFS='|' read -r method path query <<< "$parsed"
    
    # Route requests
    case "$path" in
        "/" | "/greet")
            handle_greet "$query"
            ;;
        "/health")
            handle_health
            ;;
        "/languages")
            handle_languages
            ;;
        *)
            handle_404
            ;;
    esac
}

# Function to start server
start_server() {
    log "${GREEN}Starting Bash Hello World server on http://$HOST:$PORT${NC}"
    log "Available endpoints:"
    log "  GET /         - Greeting endpoint"
    log "  GET /greet    - Greeting endpoint"
    log "  GET /health   - Health check"
    log "  GET /languages - Available languages"
    log ""
    log "Press Ctrl+C to stop the server"
    
    # Check if netcat is available
    if ! command -v nc &> /dev/null; then
        echo -e "${RED}Error: netcat (nc) is required but not installed${NC}" >&2
        exit 1
    fi
    
    # Start server loop
    while true; do
        # Use netcat to listen for connections
        nc -l -p "$PORT" -q 1 < <(handle_request) || {
            log "${YELLOW}Connection closed${NC}"
        }
    done
}

# Function to show server usage
show_server_usage() {
    cat << EOF
Bash Hello World HTTP Server

Usage: $0 [OPTIONS]

Options:
    -p, --port PORT     Port to listen on (default: 8080)
    -h, --host HOST     Host to bind to (default: 127.0.0.1)
    --help              Show this help message

Examples:
    $0                  # Start server on default port 8080
    $0 -p 3000          # Start server on port 3000
    
    # Test the server:
    curl http://localhost:8080/
    curl http://localhost:8080/greet?name=Bash&language=es
    curl http://localhost:8080/health
    curl http://localhost:8080/languages
EOF
}

# Parse server arguments
parse_server_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                PORT="$2"
                shift 2
                ;;
            -h|--host)
                HOST="$2"
                shift 2
                ;;
            --help)
                show_server_usage
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

# Main function for server
main_server() {
    parse_server_args "$@"
    start_server
}

# Run server if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_server "$@"
fi
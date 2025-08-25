#!/usr/bin/env bash
#
# install_ai_tools.sh
# Installs essential tools for AI assistant operations
# Only runs if user has sudo access without password

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Tools to install
ESSENTIAL_TOOLS=(
    "jq"        # JSON processing
    "ripgrep"   # Fast searching (rg command)
    "fd-find"   # Fast file finding
    "fzf"       # Fuzzy finder
    "tree"      # Directory visualization
    "curl"      # HTTP operations
    "wget"      # HTTP downloads
    "netcat"    # Network operations
)

OPTIONAL_TOOLS=(
    "yq"              # YAML processing
    "xmlstarlet"      # XML processing
    "silversearcher-ag" # Alternative grep
    "gh"              # GitHub CLI
    "bat"             # Better cat
    "exa"             # Better ls
    "htop"            # Process monitoring
    "tmux"            # Terminal multiplexer
    "ncdu"            # Disk usage analyzer
    "delta"           # Better git diffs
)

# Log file for installed tools
INSTALL_LOG="/tmp/ai_tools_installed.log"

# Function to check sudo access
check_sudo_access() {
    if sudo -n true 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v brew &> /dev/null; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# Function to install tool based on package manager
install_tool() {
    local tool=$1
    local pkg_manager=$2
    
    # Package name mappings for different systems
    case "$pkg_manager:$tool" in
        "apt:ripgrep"|"yum:ripgrep"|"dnf:ripgrep")
            local pkg_name="ripgrep"
            ;;
        "apt:fd-find")
            local pkg_name="fd-find"
            ;;
        "yum:fd-find"|"dnf:fd-find")
            local pkg_name="fd"
            ;;
        "apt:silversearcher-ag")
            local pkg_name="silversearcher-ag"
            ;;
        "yum:silversearcher-ag"|"dnf:silversearcher-ag")
            local pkg_name="the_silver_searcher"
            ;;
        "apt:netcat")
            local pkg_name="netcat-openbsd"
            ;;
        "yum:netcat"|"dnf:netcat")
            local pkg_name="nmap-ncat"
            ;;
        *)
            local pkg_name="$tool"
            ;;
    esac
    
    case "$pkg_manager" in
        apt)
            sudo apt-get install -y "$pkg_name" 2>/dev/null
            ;;
        yum)
            sudo yum install -y "$pkg_name" 2>/dev/null
            ;;
        dnf)
            sudo dnf install -y "$pkg_name" 2>/dev/null
            ;;
        pacman)
            sudo pacman -S --noconfirm "$pkg_name" 2>/dev/null
            ;;
        brew)
            brew install "$pkg_name" 2>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to check if tool is installed
is_installed() {
    local tool=$1
    
    # Special cases for command names
    case "$tool" in
        "ripgrep")
            command -v rg &> /dev/null
            ;;
        "fd-find")
            command -v fd &> /dev/null || command -v fdfind &> /dev/null
            ;;
        "silversearcher-ag")
            command -v ag &> /dev/null
            ;;
        "netcat")
            command -v nc &> /dev/null || command -v netcat &> /dev/null
            ;;
        *)
            command -v "$tool" &> /dev/null
            ;;
    esac
}

# Main installation function
main() {
    echo "AI Assistant Tools Installer"
    echo "============================"
    echo ""
    
    # Check sudo access
    if ! check_sudo_access; then
        echo -e "${YELLOW}⚠️  No passwordless sudo access detected.${NC}"
        echo "Debug and development tools will NOT be installed."
        echo ""
        echo "To enable tool installation, configure passwordless sudo for:"
        echo "  - Package installation commands (apt, yum, dnf, etc.)"
        echo ""
        echo "Essential tools that would be installed:"
        for tool in "${ESSENTIAL_TOOLS[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo "Optional tools that would be installed:"
        for tool in "${OPTIONAL_TOOLS[@]}"; do
            echo "  - $tool"
        done
        exit 0
    fi
    
    echo -e "${GREEN}✓ Sudo access available${NC}"
    echo ""
    
    # Detect package manager
    PKG_MANAGER=$(detect_package_manager)
    if [[ "$PKG_MANAGER" == "unknown" ]]; then
        echo -e "${RED}✗ Unable to detect package manager${NC}"
        exit 1
    fi
    echo "Detected package manager: $PKG_MANAGER"
    echo ""
    
    # Clear/create install log
    > "$INSTALL_LOG"
    
    # Install essential tools
    echo "Installing essential tools..."
    for tool in "${ESSENTIAL_TOOLS[@]}"; do
        if is_installed "$tool"; then
            echo -e "  ${GREEN}✓${NC} $tool (already installed)"
        else
            echo -n "  Installing $tool..."
            if install_tool "$tool" "$PKG_MANAGER"; then
                echo -e " ${GREEN}done${NC}"
                echo "$tool" >> "$INSTALL_LOG"
            else
                echo -e " ${YELLOW}failed${NC}"
            fi
        fi
    done
    echo ""
    
    # Ask about optional tools
    read -p "Install optional development tools? [y/N]: " install_optional
    if [[ "$install_optional" =~ ^[Yy]$ ]]; then
        echo "Installing optional tools..."
        for tool in "${OPTIONAL_TOOLS[@]}"; do
            if is_installed "$tool"; then
                echo -e "  ${GREEN}✓${NC} $tool (already installed)"
            else
                echo -n "  Installing $tool..."
                if install_tool "$tool" "$PKG_MANAGER"; then
                    echo -e " ${GREEN}done${NC}"
                    echo "$tool" >> "$INSTALL_LOG"
                else
                    echo -e " ${YELLOW}failed (may not be available)${NC}"
                fi
            fi
        done
    fi
    
    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo "Installed tools log: $INSTALL_LOG"
    echo ""
    echo "To uninstall these tools later, run:"
    echo "  ./uninstall_ai_tools.sh"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
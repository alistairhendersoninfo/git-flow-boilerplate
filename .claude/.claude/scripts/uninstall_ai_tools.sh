#!/usr/bin/env bash
#
# uninstall_ai_tools.sh
# Uninstalls AI assistant tools that were installed by install_ai_tools.sh
# Only removes tools that were actually installed by the install script

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file from installation
INSTALL_LOG="/tmp/ai_tools_installed.log"

# All possible tools that might have been installed
ALL_TOOLS=(
    "jq"
    "ripgrep"
    "fd-find"
    "fzf"
    "tree"
    "curl"
    "wget"
    "netcat"
    "yq"
    "xmlstarlet"
    "silversearcher-ag"
    "gh"
    "bat"
    "exa"
    "htop"
    "tmux"
    "ncdu"
    "delta"
)

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

# Function to uninstall tool based on package manager
uninstall_tool() {
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
            sudo apt-get remove -y "$pkg_name" 2>/dev/null
            ;;
        yum)
            sudo yum remove -y "$pkg_name" 2>/dev/null
            ;;
        dnf)
            sudo dnf remove -y "$pkg_name" 2>/dev/null
            ;;
        pacman)
            sudo pacman -R --noconfirm "$pkg_name" 2>/dev/null
            ;;
        brew)
            brew uninstall "$pkg_name" 2>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to check if tool is still needed by system
is_system_critical() {
    local tool=$1
    
    # Tools that should never be removed as they might be system critical
    case "$tool" in
        "curl"|"wget"|"netcat")
            return 0  # These are often system dependencies
            ;;
        *)
            return 1
            ;;
    esac
}

# Main uninstallation function
main() {
    echo "AI Assistant Tools Uninstaller"
    echo "=============================="
    echo ""
    
    # Check sudo access
    if ! check_sudo_access; then
        echo -e "${RED}✗ No passwordless sudo access detected.${NC}"
        echo "Cannot uninstall tools without sudo access."
        exit 1
    fi
    
    # Detect package manager
    PKG_MANAGER=$(detect_package_manager)
    if [[ "$PKG_MANAGER" == "unknown" ]]; then
        echo -e "${RED}✗ Unable to detect package manager${NC}"
        exit 1
    fi
    echo "Detected package manager: $PKG_MANAGER"
    echo ""
    
    # Check for install log
    if [[ -f "$INSTALL_LOG" ]]; then
        echo "Found installation log: $INSTALL_LOG"
        echo "Will only remove tools that were installed by install_ai_tools.sh"
        echo ""
        
        # Read tools from log
        mapfile -t TOOLS_TO_REMOVE < "$INSTALL_LOG"
        
        if [[ ${#TOOLS_TO_REMOVE[@]} -eq 0 ]]; then
            echo "No tools found in installation log."
            exit 0
        fi
        
        echo "Tools to remove:"
        for tool in "${TOOLS_TO_REMOVE[@]}"; do
            if is_system_critical "$tool"; then
                echo -e "  - $tool ${YELLOW}(system critical - will skip)${NC}"
            else
                echo "  - $tool"
            fi
        done
        echo ""
        
        read -p "Proceed with uninstallation? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Uninstallation cancelled."
            exit 0
        fi
        
        echo ""
        echo "Uninstalling tools..."
        for tool in "${TOOLS_TO_REMOVE[@]}"; do
            if is_system_critical "$tool"; then
                echo -e "  ${YELLOW}⚠${NC} Skipping $tool (system critical)"
            else
                echo -n "  Removing $tool..."
                if uninstall_tool "$tool" "$PKG_MANAGER"; then
                    echo -e " ${GREEN}done${NC}"
                else
                    echo -e " ${YELLOW}failed (may already be removed)${NC}"
                fi
            fi
        done
        
        # Clean up log file
        rm -f "$INSTALL_LOG"
        
    else
        echo -e "${YELLOW}No installation log found.${NC}"
        echo ""
        echo "Would you like to remove ALL AI assistant tools?"
        echo "This will attempt to remove:"
        for tool in "${ALL_TOOLS[@]}"; do
            if is_system_critical "$tool"; then
                echo -e "  - $tool ${YELLOW}(system critical - will skip)${NC}"
            else
                echo "  - $tool"
            fi
        done
        echo ""
        echo -e "${RED}⚠️  Warning: This may remove tools installed by other means!${NC}"
        read -p "Proceed with full uninstallation? [y/N]: " confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo ""
            echo "Uninstalling all AI tools..."
            for tool in "${ALL_TOOLS[@]}"; do
                if is_system_critical "$tool"; then
                    echo -e "  ${YELLOW}⚠${NC} Skipping $tool (system critical)"
                else
                    echo -n "  Removing $tool..."
                    if uninstall_tool "$tool" "$PKG_MANAGER"; then
                        echo -e " ${GREEN}done${NC}"
                    else
                        echo -e " ${YELLOW}not installed or failed${NC}"
                    fi
                fi
            done
        else
            echo "Uninstallation cancelled."
            exit 0
        fi
    fi
    
    echo ""
    echo -e "${GREEN}Uninstallation complete!${NC}"
    
    # Optional: clean up package manager cache
    echo ""
    read -p "Clean package manager cache? [y/N]: " clean_cache
    if [[ "$clean_cache" =~ ^[Yy]$ ]]; then
        case "$PKG_MANAGER" in
            apt)
                sudo apt-get autoremove -y
                sudo apt-get autoclean
                ;;
            yum)
                sudo yum clean all
                ;;
            dnf)
                sudo dnf clean all
                ;;
            pacman)
                sudo pacman -Sc --noconfirm
                ;;
            *)
                echo "Cache cleaning not supported for $PKG_MANAGER"
                ;;
        esac
        echo -e "${GREEN}Cache cleaned!${NC}"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
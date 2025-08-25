#!/usr/bin/env bash
#
# install_claude_instructions.sh
# Sets up Claude AI assistant configuration for new projects
# 1. Creates settings.local.json from selected template
# 2. Adds file organization instructions to CLAUDE.md

set -euo pipefail

CLAUDE_MD_FILE="../CLAUDE.md"
ENV_FILE=".env"
CLAUDE_DIR=$(dirname "$(realpath "$0")")
SETTINGS_FILE="settings.local.json"
SAFE_TEMPLATE="base-settings-template.local.json"
LOCAL_TEMPLATE="base-local-installation-template-settings.local.json"
FILE_ORG_SECTION="## File Organization"

# Function to load environment variables from .env file
load_env() {
    local env_path="$CLAUDE_DIR/$ENV_FILE"
    if [[ -f "$env_path" ]]; then
        # Source the .env file
        set -a  # Export all variables
        source "$env_path"
        set +a  # Stop exporting
    fi
}

# Function to save environment variable to .env file
save_env_var() {
    local var_name="$1"
    local var_value="$2"
    local env_path="$CLAUDE_DIR/$ENV_FILE"
    
    # Create .env file if it doesn't exist
    if [[ ! -f "$env_path" ]]; then
        cat > "$env_path" << 'EOF'
# Claude AI Assistant Configuration
# This file stores user preferences for project setup

# GitHub Configuration
GITHUB_USERNAME=""
GITHUB_DEFAULT_BRANCH=main

# Documentation Configuration  
DOCS_SITE_NAME="Project Documentation"
DOCS_THEME_PRIMARY=blue

# Project Defaults
DEFAULT_LICENSE=MIT
DEFAULT_PYTHON_VERSION=3.11
EOF
    fi
    
    # Update or add the variable
    if grep -q "^${var_name}=" "$env_path"; then
        # Update existing variable
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^${var_name}=.*|${var_name}=${var_value}|" "$env_path"
        else
            sed -i "s|^${var_name}=.*|${var_name}=${var_value}|" "$env_path"
        fi
    else
        # Add new variable
        echo "${var_name}=${var_value}" >> "$env_path"
    fi
}

# Function to prompt for and store GitHub username
setup_github_config() {
    load_env
    
    # Show current username if available
    if [[ -n "${GITHUB_USERNAME:-}" && "$GITHUB_USERNAME" != '""' && "$GITHUB_USERNAME" != "" ]]; then
        echo "Current GitHub username: $GITHUB_USERNAME"
        read -p "Keep this username? [Y/n]: " keep_username
        if [[ ! "$keep_username" =~ ^[Nn]$ ]]; then
            return 0
        fi
    fi
    
    # Prompt for GitHub username
    echo ""
    echo "📱 GitHub Configuration"
    echo "======================="
    echo "This username will be used for:"
    echo "  - Documentation site URLs (username.github.io/projectname)"
    echo "  - GitHub Actions workflows"
    echo "  - Repository links in documentation"
    echo ""
    
    local github_user=""
    while [[ -z "$github_user" ]]; do
        read -p "Enter your GitHub username: " github_user
        if [[ -z "$github_user" ]]; then
            echo "❌ GitHub username cannot be empty"
        fi
    done
    
    # Save to .env file
    save_env_var "GITHUB_USERNAME" "$github_user"
    export GITHUB_USERNAME="$github_user"
    
    echo "✅ GitHub username saved: $github_user"
    echo "💾 Stored in: $CLAUDE_DIR/$ENV_FILE"
}

# Function to create settings.local.json from selected template
create_settings_file() {
    if [[ -f "$SETTINGS_FILE" ]]; then
        echo "settings.local.json already exists"
        return 0
    fi
    
    # Ask user which mode
    echo "What type of work will Claude be doing?"
    echo "1) Development with remote installation (default - safe)"
    echo "2) Local installation (allows local install commands)"
    echo ""
    read -p "Enter choice [1-2] (default: 1): " choice
    
    # Default to safe option
    choice=${choice:-1}
    
    local template_file=""
    case $choice in
        1)
            template_file="$SAFE_TEMPLATE"
            echo "Using safe template (development with remote installation)"
            ;;
        2)
            template_file="$LOCAL_TEMPLATE"
            echo "⚠️  Using local installation template (allows local install)"
            ;;
        *)
            echo "Invalid choice, using safe default"
            template_file="$SAFE_TEMPLATE"
            ;;
    esac
    
    if [[ ! -f "$template_file" ]]; then
        echo "Error: Template file $template_file not found"
        exit 1
    fi
    
    # Copy template to settings file (excluding _instructions if present)
    if command -v jq &> /dev/null; then
        jq 'del(._instructions)' "$template_file" > "$SETTINGS_FILE"
    else
        cp "$template_file" "$SETTINGS_FILE"
    fi
    
    echo "Created settings.local.json from $template_file"
}

# Function to create TODO.md from template
create_todo_file() {
    local todo_file="TODO.md"
    local template_file=".claude/templates/TODO.md"
    
    if [[ -f "$todo_file" ]]; then
        echo "TODO.md already exists"
        return 0
    fi
    
    if [[ -f "$template_file" ]]; then
        cp "$template_file" "$todo_file"
        echo "Created TODO.md from template"
    else
        echo "Warning: TODO.md template not found"
    fi
}

# Function to create task management documentation
create_task_management_file() {
    local task_mgmt_file=".claude/TASK-MANAGEMENT.md"
    local template_file=".claude/templates/TASK-MANAGEMENT.md"
    
    if [[ -f "$task_mgmt_file" ]]; then
        echo "Task management file already exists"
        return 0
    fi
    
    if [[ -f "$template_file" ]]; then
        cp "$template_file" "$task_mgmt_file"
        echo "Created .claude/TASK-MANAGEMENT.md from template"
    else
        echo "Warning: Task management template not found"
    fi
}

# Function to create development workflow documentation
create_development_workflow_file() {
    local dev_workflow_file=".claude/DEVELOPMENT-WORKFLOW.md"
    local template_file=".claude/templates/DEVELOPMENT-WORKFLOW.md"
    
    if [[ -f "$dev_workflow_file" ]]; then
        echo "Development workflow file already exists"
        return 0
    fi
    
    if [[ -f "$template_file" ]]; then
        cp "$template_file" "$dev_workflow_file"
        echo "Created .claude/DEVELOPMENT-WORKFLOW.md from template"
    else
        echo "Warning: Development workflow template not found"
    fi
}

# Function to copy GitHub workflows from templates
copy_github_workflows() {
    local template_workflow_dir=".claude/templates/.github/workflows"
    local target_workflow_dir="../.github/workflows"
    
    if [[ ! -d "$template_workflow_dir" ]]; then
        echo "No GitHub workflow templates found"
        return 0
    fi
    
    # Create target directory if it doesn't exist
    mkdir -p "$target_workflow_dir"
    
    # Copy workflow files if they don't exist
    local copied_count=0
    for template_file in "$template_workflow_dir"/*.yml; do
        if [[ -f "$template_file" ]]; then
            local filename=$(basename "$template_file")
            local target_file="$target_workflow_dir/$filename"
            
            if [[ ! -f "$target_file" ]]; then
                cp "$template_file" "$target_file"
                echo "Created GitHub workflow: .github/workflows/$filename"
                ((copied_count++))
            else
                echo "GitHub workflow already exists: .github/workflows/$filename"
            fi
        fi
    done
    
    if [[ $copied_count -gt 0 ]]; then
        echo "✅ Copied $copied_count GitHub workflow(s)"
        echo "💡 Enable GitHub Pages in repository Settings → Pages → Source: GitHub Actions"
    fi
}

# Function to add file organization section to CLAUDE.md
add_file_organization() {
    # Check if file organization section already exists
    if grep -q "$FILE_ORG_SECTION" "$CLAUDE_MD_FILE"; then
        echo "File organization section already exists in CLAUDE.md"
        return 0
    fi
    
    if [[ ! -f "$CLAUDE_MD_FILE" ]]; then
        echo "Error: CLAUDE.md not found at $CLAUDE_MD_FILE"
        exit 1
    fi
    
    # Add file organization section
    cat >> "$CLAUDE_MD_FILE" << 'EOF'

## File Organization

### Project Documentation (for users):
- Root `.md` files - Project overview, installation, usage
- `docs/` directory - Technical documentation and guides
- `README.md` - Main project documentation

### AI Assistant Instructions (for Claude behavior):
- `.claude/` directory contains AI assistant behavioral instructions
- Always read relevant `.claude/*.md` files for context
- `.claude/settings.local.json` - Current permission settings

**IMPORTANT**: Files in `.claude/` are AI assistant instructions, not project documentation.

## Task Management

**⚠️ CRITICAL: Read `.claude/TASK-MANAGEMENT.md` for complete task management instructions.**

### Quick Reference:
1. **Always read TODO.md first** when starting any conversation
2. **Prioritize "In Progress" tasks** from the Current Tasks section
3. **Update task status** as work progresses
4. **User commands**: "scan the tasks" (active work with types/priority) | "show todo" (complete list)

### File Usage:
- **TODO.md** - Persistent task tracking (survives session restarts)
- **TodoWrite tool** - Temporary session-based todos
- **.claude/TASK-MANAGEMENT.md** - Complete workflow documentation

**See `.claude/TASK-MANAGEMENT.md` for detailed workflow, commands, and best practices.**

EOF
    
    echo "Added file organization section to CLAUDE.md"
}

# Main execution
main() {
    echo "Setting up Claude AI assistant configuration..."
    
    # Setup GitHub configuration first
    setup_github_config
    
    # Create settings file from template
    create_settings_file
    
    # Create TODO.md from template
    create_todo_file
    
    # Create task management documentation
    create_task_management_file
    
    # Create development workflow documentation  
    create_development_workflow_file
    
    # Copy GitHub workflows
    copy_github_workflows
    
    # Add file organization to CLAUDE.md
    add_file_organization
    
    echo "Claude configuration setup complete"
    echo ""
    
    # Ask about AI tools installation
    if [[ "${choice:-1}" == "2" ]]; then
        echo "🤖 Local installation mode detected"
        echo "Would you like to install AI assistant tools (jq, ripgrep, etc.)?"
        read -p "Install AI tools? [Y/n]: " install_ai_tools
        
        if [[ ! "$install_ai_tools" =~ ^[Nn]$ ]]; then
            if [[ -f ".claude/scripts/install_ai_tools.sh" ]]; then
                .claude/scripts/install_ai_tools.sh
            else
                echo "⚠️  AI tools installer not found"
            fi
        fi
    fi
    
    # Ask about documentation setup
    echo ""
    echo "📚 Would you like to set up Git documentation system?"
    echo "This creates professional documentation sites like docs.github.com"
    echo ""
    echo "ℹ️  GitHub Pages Setup:"
    echo "   • Public repos: Automatic setup with free GitHub"
    echo "   • Private repos: Requires GitHub Pro/Team/Enterprise plan"
    echo "   • The workflows will check your plan and enable Pages automatically"
    echo "   • If automatic setup fails, go to Settings → Pages → Source: 'GitHub Actions'"
    echo ""
    read -p "Set up documentation? [Y/n]: " setup_docs
    
    if [[ ! "$setup_docs" =~ ^[Nn]$ ]]; then
        if [[ -f ".claude/create_git_documentation.sh" ]]; then
            echo ""
            echo "🚀 Launching documentation setup..."
            .claude/create_git_documentation.sh
        else
            echo "⚠️  Documentation setup script not found"
        fi
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
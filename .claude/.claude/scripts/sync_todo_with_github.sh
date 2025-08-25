#!/usr/bin/env bash
#
# sync_todo_with_github.sh
# Bidirectional sync between TODO.md and GitHub Projects
# Usage: sync_todo_with_github.sh <project-number> [direction]
#        direction: to-github | from-github | both (default: both)
#

set -euo pipefail

PROJECT_NUMBER="$1"
DIRECTION="${2:-both}"
TODO_FILE="TODO.md"

# Validate inputs
if [[ -z "$PROJECT_NUMBER" ]]; then
    echo "Error: Project number is required"
    echo "Usage: $0 <project-number> [to-github|from-github|both]"
    exit 1
fi

echo "🔄 Syncing TODO.md ↔ GitHub Project #$PROJECT_NUMBER (direction: $DIRECTION)"

# Function to check if task exists in GitHub Project
task_exists_in_github() {
    local task_title="$1"
    local project_items="$2"
    echo "$project_items" | jq -r '.items[].title' | grep -Fxq "$task_title"
}

# Function: Sync TODO.md → GitHub Projects
sync_to_github() {
    echo "📤 Syncing TODO.md → GitHub Projects..."
    
    if [[ ! -f "$TODO_FILE" ]]; then
        echo "⚠️  TODO.md not found, skipping to-github sync"
        return 0
    fi
    
    # Get existing project items
    local existing_items
    existing_items=$(gh project item-list "$PROJECT_NUMBER" --format json 2>/dev/null || echo '{"items":[]}')
    
    local current_section=""
    local new_tasks=0
    
    while IFS= read -r line; do
        # Detect sections
        if [[ $line == "## 📋 Current Tasks"* ]]; then
            current_section="current"
        elif [[ $line == "## 🎯 Next Tasks"* ]]; then
            current_section="next"
        elif [[ $line == "## 💡 Ideas"* ]]; then
            current_section="ideas"
        elif [[ $line =~ ^-\ \[\ \]\ (.+)$ ]]; then
            # Uncompleted task
            local task_title="${BASH_REMATCH[1]}"
            local clean_title
            clean_title=$(echo "$task_title" | sed 's/~~//g' | sed 's/\*\*//g' | sed 's/__//g')
            
            if ! task_exists_in_github "$clean_title" "$existing_items"; then
                echo "  Adding: $clean_title"
                gh project item-add "$PROJECT_NUMBER" --title "$clean_title" --body "Added from TODO.md ($current_section section)" >/dev/null
                ((new_tasks++))
            fi
        elif [[ $line =~ ^-\ \[x\]\ (.+)$ ]]; then
            # Completed task
            local task_title="${BASH_REMATCH[1]}"
            local clean_title
            clean_title=$(echo "$task_title" | sed 's/~~//g' | sed 's/\*\*//g' | sed 's/__//g' | sed 's/ (completed.*)$//')
            
            if [[ $current_section == "completed" ]] && ! task_exists_in_github "$clean_title" "$existing_items"; then
                echo "  Adding completed: $clean_title"
                gh project item-add "$PROJECT_NUMBER" --title "$clean_title" --body "Completed task from TODO.md" >/dev/null
                ((new_tasks++))
            fi
        fi
    done < "$TODO_FILE"
    
    echo "✅ Added $new_tasks new tasks to GitHub Project"
}

# Function: Sync GitHub Projects → TODO.md
sync_from_github() {
    echo "📥 Syncing GitHub Projects → TODO.md..."
    
    # Backup existing TODO.md
    if [[ -f "$TODO_FILE" ]]; then
        cp "$TODO_FILE" "${TODO_FILE}.backup"
    fi
    
    # Get project information
    local project_info project_title project_url
    project_info=$(gh project view "$PROJECT_NUMBER" --format json 2>/dev/null)
    project_title=$(echo "$project_info" | jq -r '.title')
    project_url=$(echo "$project_info" | jq -r '.url')
    
    if [[ "$project_title" == "null" ]]; then
        echo "❌ Could not fetch project information"
        return 1
    fi
    
    # Get all project items
    local project_items
    project_items=$(gh project item-list "$PROJECT_NUMBER" --format json 2>/dev/null || echo '{"items":[]}')
    
    # Generate new TODO.md
    cat > "$TODO_FILE" << EOF
# ${project_title} TODO List

## 📋 Current Tasks (In Progress)

EOF

    # Add current/in-progress tasks
    local current_tasks
    current_tasks=$(echo "$project_items" | jq -r '.items[] | select(.status?.name == "In Progress" or .status?.name == null) | .title' 2>/dev/null || true)
    if [[ -n "$current_tasks" && "$current_tasks" != "" ]]; then
        echo "$current_tasks" | while IFS= read -r task; do
            [[ -n "$task" ]] && echo "- [ ] $task" >> "$TODO_FILE"
        done
    else
        echo "- [ ] No current tasks" >> "$TODO_FILE"
    fi

    cat >> "$TODO_FILE" << 'EOF'

## 🎯 Next Tasks (Planned)

EOF

    # Add planned tasks
    local next_tasks
    next_tasks=$(echo "$project_items" | jq -r '.items[] | select(.status?.name == "Draft" or .status?.name == "To Do" or .status?.name == "Todo") | .title' 2>/dev/null || true)
    if [[ -n "$next_tasks" && "$next_tasks" != "" ]]; then
        echo "$next_tasks" | while IFS= read -r task; do
            [[ -n "$task" ]] && echo "- [ ] $task" >> "$TODO_FILE"
        done
    else
        echo "- [ ] No planned tasks" >> "$TODO_FILE"
    fi

    cat >> "$TODO_FILE" << 'EOF'

## 💡 Ideas & Future Tasks

EOF

    # Add ideas/backlog tasks
    local ideas_tasks
    ideas_tasks=$(echo "$project_items" | jq -r '.items[] | select(.status?.name == "Ideas" or .status?.name == "Backlog" or .status?.name == "Future") | .title' 2>/dev/null || true)
    if [[ -n "$ideas_tasks" && "$ideas_tasks" != "" ]]; then
        echo "$ideas_tasks" | while IFS= read -r task; do
            [[ -n "$task" ]] && echo "- [ ] $task" >> "$TODO_FILE"
        done
    else
        echo "- [ ] No ideas or future tasks" >> "$TODO_FILE"
    fi

    cat >> "$TODO_FILE" << 'EOF'

## ✅ Completed Tasks

EOF

    # Add completed tasks
    local completed_tasks
    completed_tasks=$(echo "$project_items" | jq -r '.items[] | select(.status?.name == "Done" or .status?.name == "Completed") | .title' 2>/dev/null || true)
    local current_date
    current_date=$(date +%Y-%m-%d)
    if [[ -n "$completed_tasks" && "$completed_tasks" != "" ]]; then
        echo "$completed_tasks" | while IFS= read -r task; do
            [[ -n "$task" ]] && echo "- [x] ~~$task~~ (completed on $current_date)" >> "$TODO_FILE"
        done
    fi

    cat >> "$TODO_FILE" << EOF

---

## 📝 Notes

### GitHub Project Integration:
- **Project**: $project_title
- **URL**: $project_url  
- **Project Number**: $PROJECT_NUMBER
- Run \`.claude/scripts/sync_todo_with_github.sh $PROJECT_NUMBER\` for manual sync

### Task Management Rules:
- **Current Tasks**: What you're actively working on
- **Next Tasks**: What's planned and prioritized
- **Ideas**: Future possibilities, not urgent
- **Completed**: Keep recent completions for reference

EOF

    echo "✅ TODO.md updated from GitHub Project"
    [[ -f "${TODO_FILE}.backup" ]] && echo "📋 Backup saved: ${TODO_FILE}.backup"
}

# Main execution
case $DIRECTION in
    "to-github")
        sync_to_github
        ;;
    "from-github")
        sync_from_github
        ;;
    "both")
        sync_to_github
        echo ""
        sync_from_github
        ;;
    *)
        echo "Error: Invalid direction. Use: to-github, from-github, or both"
        exit 1
        ;;
esac

echo ""
echo "🎉 Sync complete! Use 'gh project view $PROJECT_NUMBER --web' to view project"
# GitHub Projects Integration

## 🎯 Overview

This guide covers integrating our TODO.md system with GitHub Projects for project management. When a user says "create project and task", Claude will create both a GitHub Project and sync with our TODO.md file.

## 📋 GitHub Projects vs Issues/PRs

### **GitHub Projects (What we're using):**
- 📊 **Project management** across multiple repositories
- ✅ **Tasks/Items** - Work items in project boards
- 📈 **Custom fields** - Status, Priority, Assignee, Sprint, etc.
- 🔄 **Workflows** - Auto-move items between columns
- 🎯 **Views** - Board, Table, Roadmap views

### **Issues/PRs (Different):**
- 🐛 **Issues** - Bug reports, feature requests (repository-specific)
- 🔀 **Pull Requests** - Code changes, merge requests
- 📝 **Discussions** - Community conversations

## 🚀 GitHub CLI Commands for Projects

### **Authentication Setup**
```bash
# Authenticate with GitHub (required first)
gh auth login

# Verify authentication and permissions
gh auth status

# Check if you have Projects access
gh api user --jq '.login'
```

### **Project Management**

#### **Create Project**
```bash
# Create new project (organization)
gh project create --owner "organization-name" --title "project-name-development"

# Create new project (personal)
gh project create --title "project-name-development"

# Get project details
gh project list --owner "username-or-org"
gh project view <PROJECT_NUMBER> --owner "username-or-org"
```

#### **Get Project Information**
```bash
# List projects
gh project list

# Get project ID and details
gh project view 1 --format json | jq '.id'

# Get project URL
gh project view 1 --web
```

### **Task/Item Management**

#### **Add Tasks to Project**
```bash
# Add draft item (task)
gh project item-add <PROJECT_NUMBER> --body "Task description"

# Add item with title
gh project item-add <PROJECT_NUMBER> --title "Task Title" --body "Detailed description"

# Add multiple items
gh project item-add <PROJECT_NUMBER> --title "Setup documentation"
gh project item-add <PROJECT_NUMBER> --title "Create deployment scripts"
gh project item-add <PROJECT_NUMBER> --title "Write tests"
```

#### **Update Task Status**
```bash
# List project fields to get field IDs
gh project field-list <PROJECT_NUMBER>

# Update status field (requires field ID and option ID)
gh project item-edit --project <PROJECT_NUMBER> --id <ITEM_ID> --field-id <STATUS_FIELD_ID> --single-select-option-id <STATUS_OPTION_ID>

# Update other fields
gh project item-edit --project <PROJECT_NUMBER> --id <ITEM_ID> --field-id <ASSIGNEE_FIELD_ID> --text "username"
gh project item-edit --project <PROJECT_NUMBER> --id <ITEM_ID> --field-id <PRIORITY_FIELD_ID> --single-select-option-id <PRIORITY_OPTION_ID>
```

#### **List and Query Tasks**
```bash
# List all items in project
gh project item-list <PROJECT_NUMBER>

# Get specific item details
gh project item-view --project <PROJECT_NUMBER> --id <ITEM_ID>

# List items with specific status
gh project item-list <PROJECT_NUMBER> --format json | jq '.items[] | select(.status.name == "In Progress")'
```

## 🔧 Project Structure and Fields

### **Default Project Structure**
```
Project: project-name-development
├── 📋 Backlog (Status: Draft)
├── 🔄 In Progress (Status: In Progress)  
├── 👁️ In Review (Status: In Review)
└── ✅ Done (Status: Done)
```

### **Standard Fields**
- **Status**: Draft → In Progress → In Review → Done
- **Priority**: 🔴 High, 🟡 Medium, 🔵 Low
- **Assignees**: Team members
- **Labels**: Type of work (bug, feature, docs, etc.)
- **Iteration**: Sprint or milestone

### **Custom Fields Setup**
```bash
# Add custom field (Priority)
gh api graphql -f query='
mutation {
  addProjectV2Field(input: {
    projectId: "PROJECT_ID"
    dataType: SINGLE_SELECT
    name: "Priority"
    singleSelectOptions: [
      {name: "High", color: RED}
      {name: "Medium", color: YELLOW}
      {name: "Low", color: BLUE}
    ]
  }) {
    projectV2Field {
      id
    }
  }
}'
```

## 📱 Integration Workflows

### **Create Project and Tasks Workflow**

When user says: **"create project and task"**

```bash
#!/bin/bash
# create_github_project.sh

PROJECT_NAME="$1"
OWNER="$2"  # Optional: organization or username

# 1. Create GitHub Project
echo "🚀 Creating GitHub Project: ${PROJECT_NAME}-development"
PROJECT_NUMBER=$(gh project create --title "${PROJECT_NAME}-development" --owner "$OWNER" --format json | jq -r '.number')

# 2. Add initial tasks from TODO.md
echo "📋 Adding tasks from TODO.md..."
while IFS= read -r line; do
    if [[ $line =~ ^-\ \[\ \]\ (.+)$ ]]; then
        task_title="${BASH_REMATCH[1]}"
        echo "  Adding task: $task_title"
        gh project item-add "$PROJECT_NUMBER" --title "$task_title"
    fi
done < TODO.md

# 3. Get project URL
PROJECT_URL=$(gh project view "$PROJECT_NUMBER" --format json | jq -r '.url')
echo "✅ Project created: $PROJECT_URL"
```

### **Sync TODO.md to GitHub Projects**

```bash
#!/bin/bash
# sync_todo_to_github.sh

PROJECT_NUMBER="$1"

echo "🔄 Syncing TODO.md to GitHub Projects..."

# Parse TODO.md sections
current_section=""
while IFS= read -r line; do
    # Detect sections
    if [[ $line == "## 📋 Current Tasks"* ]]; then
        current_section="current"
    elif [[ $line == "## 🎯 Next Tasks"* ]]; then
        current_section="next"
    elif [[ $line == "## ✅ Completed Tasks"* ]]; then
        current_section="completed"
    elif [[ $line =~ ^-\ \[\ \]\ (.+)$ ]]; then
        # Uncompleted task
        task_title="${BASH_REMATCH[1]}"
        case $current_section in
            "current")
                echo "  Adding current task: $task_title"
                gh project item-add "$PROJECT_NUMBER" --title "$task_title"
                # TODO: Set status to "In Progress"
                ;;
            "next")
                echo "  Adding next task: $task_title"
                gh project item-add "$PROJECT_NUMBER" --title "$task_title"
                # TODO: Set status to "Draft"
                ;;
        esac
    elif [[ $line =~ ^-\ \[x\]\ (.+)$ ]]; then
        # Completed task
        task_title="${BASH_REMATCH[1]}"
        if [[ $current_section == "completed" ]]; then
            echo "  Adding completed task: $task_title"
            gh project item-add "$PROJECT_NUMBER" --title "$task_title"
            # TODO: Set status to "Done"
        fi
    fi
done < TODO.md

echo "✅ Sync complete"
```

### **Sync GitHub Projects to TODO.md**

```bash
#!/bin/bash
# sync_github_to_todo.sh

PROJECT_NUMBER="$1"

echo "🔄 Syncing GitHub Projects to TODO.md..."

# Backup existing TODO.md
cp TODO.md TODO.md.backup

# Generate new TODO.md from GitHub Project
cat > TODO.md << 'EOF'
# Project TODO List

## 📋 Current Tasks (In Progress)

EOF

# Get items with "In Progress" status
gh project item-list "$PROJECT_NUMBER" --format json | jq -r '.items[] | select(.status.name == "In Progress") | "- [ ] " + .title' >> TODO.md

cat >> TODO.md << 'EOF'

## 🎯 Next Tasks (Planned)

EOF

# Get items with "Draft" status
gh project item-list "$PROJECT_NUMBER" --format json | jq -r '.items[] | select(.status.name == "Draft") | "- [ ] " + .title' >> TODO.md

cat >> TODO.md << 'EOF'

## ✅ Completed Tasks

EOF

# Get items with "Done" status
gh project item-list "$PROJECT_NUMBER" --format json | jq -r '.items[] | select(.status.name == "Done") | "- [x] " + .title + " (completed)"' >> TODO.md

cat >> TODO.md << 'EOF'

---

## 📝 Notes

### GitHub Project Integration:
- This TODO.md is synced with GitHub Projects
- Changes made here can be synced to GitHub Projects
- Run `sync_todo_to_github.sh` to push changes
- Run `sync_github_to_todo.sh` to pull changes

EOF

echo "✅ TODO.md updated from GitHub Project"
```

## 🤖 Claude Integration Instructions

### **When User Says: "create project and task"**

1. **Extract project name** from context or ask user
2. **Run project creation**:
   ```bash
   # Create GitHub Project
   gh project create --title "{project-name}-development"
   
   # Add initial tasks from TODO.md (if exists)
   # Or create basic development tasks
   ```

3. **Create/Update TODO.md** with GitHub Project link
4. **Confirm creation** with project URL

### **When User Says: "sync todos" or "update github project"**

1. **Determine sync direction**:
   - TODO.md → GitHub Projects
   - GitHub Projects → TODO.md
   - Or bidirectional merge

2. **Run appropriate sync script**

3. **Report changes made**

### **Task Management Commands**

```bash
# User: "add task: implement user authentication"
gh project item-add <PROJECT_NUMBER> --title "implement user authentication"

# User: "mark task as done: setup database"
# Find task and update status to Done

# User: "what tasks are in progress?"
gh project item-list <PROJECT_NUMBER> --format json | jq -r '.items[] | select(.status.name == "In Progress") | .title'
```

## 📊 Project Templates

### **Development Project Template**
```bash
#!/bin/bash
# create_dev_project_template.sh

PROJECT_NAME="$1"
PROJECT_NUMBER=$(gh project create --title "${PROJECT_NAME}-development")

# Add standard development tasks
gh project item-add "$PROJECT_NUMBER" --title "📋 Project Setup and Planning"
gh project item-add "$PROJECT_NUMBER" --title "🏗️ Development Environment Setup"
gh project item-add "$PROJECT_NUMBER" --title "📚 Documentation Creation"
gh project item-add "$PROJECT_NUMBER" --title "🧪 Testing Framework Setup"
gh project item-add "$PROJECT_NUMBER" --title "🚀 Deployment Pipeline"
gh project item-add "$PROJECT_NUMBER" --title "🔍 Code Review Process"
gh project item-add "$PROJECT_NUMBER" --title "📈 Performance Monitoring"
gh project item-add "$PROJECT_NUMBER" --title "🐛 Bug Tracking System"
gh project item-add "$PROJECT_NUMBER" --title "✅ Final Testing and QA"
gh project item-add "$PROJECT_NUMBER" --title "🎉 Project Launch"
```

### **Documentation Project Template**
```bash
#!/bin/bash
# create_docs_project_template.sh

PROJECT_NAME="$1"
PROJECT_NUMBER=$(gh project create --title "${PROJECT_NAME}-documentation")

# Add documentation-specific tasks
gh project item-add "$PROJECT_NUMBER" --title "📝 API Documentation"
gh project item-add "$PROJECT_NUMBER" --title "🎯 User Guide Creation"
gh project item-add "$PROJECT_NUMBER" --title "🛠️ Developer Documentation"
gh project item-add "$PROJECT_NUMBER" --title "📋 Installation Instructions"
gh project item-add "$PROJECT_NUMBER" --title "🎨 Documentation Site Setup"
gh project item-add "$PROJECT_NUMBER" --title "🔄 Documentation Review Process"
gh project item-add "$PROJECT_NUMBER" --title "🌐 Multi-language Support"
gh project item-add "$PROJECT_NUMBER" --title "📊 Analytics and Feedback"
```

## 🔍 Troubleshooting

### **Common Issues**

#### **Authentication Problems**
```bash
# Check auth status
gh auth status

# Re-authenticate if needed
gh auth login --scopes project

# Check organization permissions
gh api user/memberships/orgs
```

#### **Project Not Found**
```bash
# List all accessible projects
gh project list --owner "username-or-org"

# Verify project number/ID
gh api graphql -f query='query{viewer{projectsV2(first:10){nodes{number title}}}}'
```

#### **Permission Issues**
```bash
# Check if you have project access
gh api user --jq '.login'

# Verify organization membership
gh api orgs/ORG_NAME/members/USERNAME
```

### **API Rate Limits**
```bash
# Check rate limit status
gh api rate_limit

# Use pagination for large projects
gh project item-list PROJECT_NUMBER --limit 100
```

## 📚 Additional Resources

### **GitHub Projects API**
- [GitHub Projects API Documentation](https://docs.github.com/en/rest/projects)
- [GraphQL API for Projects](https://docs.github.com/en/graphql/reference/objects#projectv2)

### **GitHub CLI**
- [GitHub CLI Project Commands](https://cli.github.com/manual/gh_project)
- [GitHub CLI Authentication](https://cli.github.com/manual/gh_auth)

### **Integration Examples**
- See `.claude/scripts/github-project-sync.sh` for complete sync script
- See `.claude/templates/project-templates/` for project templates
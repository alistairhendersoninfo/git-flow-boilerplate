# Development Workflow System

## Task-Based Development Lifecycle

When user selects a task of type **bug**, **feature**, or **enhancement** from "scan the tasks", Claude automatically sets up a complete development environment.

## Automatic Setup Workflow

### Task Grouping by Type Detection
```bash
# Check if there are existing "In Progress" tasks of the same type
TASK_TYPE="$1"  # bug, feature, enhancement
TASK_TITLE="$2"

# Look for existing issue with same tag/type that's still open
EXISTING_ISSUE=$(gh issue list --label "$TASK_TYPE" --state open --search "in:title [$TASK_TYPE]" --json number --jq '.[0].number')
EXISTING_BRANCH=$(git branch -a | grep "${TASK_TYPE}-${EXISTING_ISSUE}" | head -1)
EXISTING_WORK_FOLDER="work/${TASK_TYPE}-${EXISTING_ISSUE}"

if [[ -n "$EXISTING_ISSUE" ]]; then
    echo "🔄 Found existing ${TASK_TYPE} issue #${EXISTING_ISSUE}"
    echo "📋 Adding '${TASK_TITLE}' to existing ${TASK_TYPE} workflow"
    
    # Add this task to the existing issue
    gh issue comment "$EXISTING_ISSUE" --body "## Additional Task: ${TASK_TITLE}

Added from GitHub Project scan:
- **Type**: ${TASK_TYPE}
- **Status**: In Progress
- **Description**: ${TASK_DESCRIPTION}

### Acceptance Criteria
- [ ] ${TASK_TITLE} completed
"
    
    # Switch to existing branch and work folder
    if [[ -n "$EXISTING_BRANCH" ]]; then
        git checkout "${EXISTING_BRANCH##*/}"
        cd "$EXISTING_WORK_FOLDER" || echo "⚠️ Work folder not found, continuing in project root"
        echo "✅ Resumed work on ${TASK_TYPE} issue #${EXISTING_ISSUE}"
        
        # Update work folder README with new task
        echo "- [ ] ${TASK_TITLE}" >> "${EXISTING_WORK_FOLDER}/README.md"
        exit 0  # Skip new issue creation
    fi
fi
```

### 1. Issue Creation (New Tasks Only)
```bash
# Create GitHub issue based on task type
gh issue create \
  --title "Task Title from GitHub Project" \
  --body "Detailed description with acceptance criteria" \
  --label "bug" \
  --assignee @me

# Capture issue number for workflow
ISSUE_NUMBER=$(gh issue list --limit 1 --json number --jq '.[0].number')
```

### 2. Branch Creation & Checkout
```bash
# Create branch based on task type and issue number
BRANCH_NAME="${TASK_TYPE}-${ISSUE_NUMBER}"

# Examples: bug-123, feature-124, enhancement-125

# Create and checkout branch
git checkout -b "$BRANCH_NAME" 
git push -u origin "$BRANCH_NAME"
```

### 3. Local Folder Structure
```bash
# Create work folder organized by task type and issue number
mkdir -p "work/${TASK_TYPE}-${ISSUE_NUMBER}"
cd "work/${TASK_TYPE}-${ISSUE_NUMBER}"

# Create standard development files
touch README.md
touch NOTES.md
mkdir -p tests
mkdir -p docs

# Initialize with task information
cat > README.md << EOF
# ${TASK_TYPE^} Issue #${ISSUE_NUMBER}

## Tasks in this ${TASK_TYPE} group:
- [ ] ${TASK_TITLE}

## Type: ${TASK_TYPE}

## Description
Multiple ${TASK_TYPE} tasks grouped together for efficient development

## Files Modified
- [ ] file1.js
- [ ] file2.js

## Testing
- [ ] Unit tests added
- [ ] Integration tests updated
- [ ] Manual testing completed

## Notes
Add additional ${TASK_TYPE} tasks to this issue as they become "In Progress"

EOF
```

### 4. Draft PR Creation
```bash
# Create draft PR linked to issue
gh pr create \
  --title "Fix #${ISSUE_NUMBER}: Task Title" \
  --body "Closes #${ISSUE_NUMBER}

## Changes
- Description of changes

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Tests added/updated
" \
  --draft \
  --head "$BRANCH_NAME" \
  --base main

# Get PR number for tracking
PR_NUMBER=$(gh pr list --head "$BRANCH_NAME" --json number --jq '.[0].number')
```

### 5. GitHub Project Task Updates
```bash
# Update the GitHub Project task with Issue and PR links
PROJECT_ITEM_ID="$1"  # From task selection
PROJECT_NUMBER="$2"   # From project configuration

# Get URLs for linking
ISSUE_URL=$(gh issue view "$ISSUE_NUMBER" --json url --jq '.url')
PR_URL=$(gh pr view "$PR_NUMBER" --json url --jq '.url')

# Update project task body/description with links
gh project item-edit \
  --project "$PROJECT_NUMBER" \
  --id "$PROJECT_ITEM_ID" \
  --body "**Development Links:**
- 🐛 **Issue**: [#${ISSUE_NUMBER}](${ISSUE_URL})
- 🔀 **PR**: [#${PR_NUMBER}](${PR_URL})
- 🌿 **Branch**: \`${BRANCH_NAME}\`
- 📁 **Work Folder**: \`work/${TASK_TYPE}-${ISSUE_NUMBER}/\`

**Original Task Description:**
${ORIGINAL_TASK_DESCRIPTION}

**Development Status:**
- [x] Issue created
- [x] Branch created  
- [x] Work folder setup
- [x] Draft PR created
- [ ] Development in progress
- [ ] Tests added
- [ ] PR ready for review
- [ ] Merged to main
"

echo "✅ Updated GitHub Project task with Issue #${ISSUE_NUMBER} and PR #${PR_NUMBER} links"
```

## Development Commands

### Git Push Intelligence
When user says **"git push"**, Claude should:

```bash
# Determine current context
CURRENT_BRANCH=$(git branch --show-current)
MAIN_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)

if [[ "$CURRENT_BRANCH" == "$MAIN_BRANCH" ]]; then
    echo "⚠️  You're on main branch. Are you sure? (y/N)"
    read -p "Push to main? " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        git push origin "$MAIN_BRANCH"
    else
        echo "Push cancelled. Switch to feature branch first."
    fi
else
    # Push feature branch and update PR
    git push origin "$CURRENT_BRANCH"
    
    # Check if PR exists and update
    if gh pr view "$CURRENT_BRANCH" &>/dev/null; then
        echo "✅ Pushed to feature branch: $CURRENT_BRANCH"
        echo "🔗 PR: $(gh pr view "$CURRENT_BRANCH" --json url --jq '.url')"
        
        # Ask if ready to mark PR as ready for review
        read -p "Mark PR as ready for review? (y/N) " ready
        if [[ "$ready" =~ ^[Yy]$ ]]; then
            gh pr ready "$CURRENT_BRANCH"
            echo "🎉 PR marked as ready for review!"
        fi
    fi
fi
```

### Production/Merge Workflow
When user says **"make production"** or **"merge code"**, Claude should:

```bash
# Complete merge workflow
CURRENT_BRANCH=$(git branch --show-current)
MAIN_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)

if [[ "$CURRENT_BRANCH" == "$MAIN_BRANCH" ]]; then
    echo "❌ Already on main branch. Switch to feature branch first."
    exit 1
fi

echo "🚀 Starting production merge workflow..."

# 1. Ensure all changes are committed
if ! git diff --quiet; then
    echo "📝 Uncommitted changes detected. Committing..."
    git add .
    git commit -m "Final changes for issue #${ISSUE_NUMBER}"
fi

# 2. Push final changes
git push origin "$CURRENT_BRANCH"

# 3. Update PR to ready status
gh pr ready "$CURRENT_BRANCH" || echo "PR already ready"

# 4. Run final checks
echo "🧪 Running final checks..."
# Add project-specific test commands here
# npm test, cargo test, pytest, etc.

# 5. Merge PR
echo "🔀 Merging PR..."
gh pr merge "$CURRENT_BRANCH" \
  --merge \
  --delete-branch \
  --body "✅ All checks passed. Ready for production."

# 6. Switch back to main and pull
git checkout "$MAIN_BRANCH"
git pull origin "$MAIN_BRANCH"

# 7. Clean up local work folder
read -p "Clean up work folder work/issue-${ISSUE_NUMBER}? (Y/n) " cleanup
if [[ ! "$cleanup" =~ ^[Nn]$ ]]; then
    rm -rf "work/issue-${ISSUE_NUMBER}"
    echo "🧹 Cleaned up work folder"
fi

# 8. Update GitHub Project status
gh project item-edit \
  --project "$PROJECT_NUMBER" \
  --id "$ITEM_ID" \
  --field-id "$STATUS_FIELD_ID" \
  --single-select-option-id "$DONE_OPTION_ID"

echo "🎉 Production deployment complete!"
echo "📊 Issue #${ISSUE_NUMBER} closed and merged to main"
echo "📋 GitHub Project task updated with complete audit trail"

# Final project task update with completion summary
gh project item-edit \
  --project "$PROJECT_NUMBER" \
  --id "$PROJECT_ITEM_ID" \
  --body "**✅ COMPLETED - Production Deployment**

**Development Links:**
- 🐛 **Issue**: [#${ISSUE_NUMBER}](${ISSUE_URL}) - **CLOSED**
- 🔀 **PR**: [#${PR_NUMBER}](${PR_URL}) - **MERGED**
- 🌿 **Branch**: \`${BRANCH_NAME}\` - **DELETED**

**Deployment Summary:**
- **Type**: ${TASK_TYPE}
- **Completed**: $(date)
- **Files Changed**: $(git diff --name-only HEAD~$(git rev-list --count HEAD ^main) HEAD | wc -l) files
- **Commits**: $(git rev-list --count HEAD ^main) commits
- **Tests**: All passing
- **Review**: Approved and merged

**Original Task:** ${ORIGINAL_TASK_DESCRIPTION}
"
```

## Task Type Specific Workflows

### Bug Workflow
```bash
# Bug-specific setup
LABELS="bug,priority-high"
BRANCH_PREFIX="bugfix"
PR_TEMPLATE="bug_report"

# Create hotfix branch for critical bugs
if [[ "$PRIORITY" == "critical" ]]; then
    git checkout -b "hotfix-${ISSUE_NUMBER}-$(date +%Y%m%d)"
    echo "🚨 Created hotfix branch for critical bug"
fi
```

### Feature Workflow  
```bash
# Feature-specific setup
LABELS="enhancement,feature"
BRANCH_PREFIX="feature"
PR_TEMPLATE="feature_request"

# Create feature branch
git checkout -b "feature-${ISSUE_NUMBER}-feature-name"

# Set up feature documentation
mkdir -p "work/issue-${ISSUE_NUMBER}/docs/feature"
touch "work/issue-${ISSUE_NUMBER}/docs/feature/README.md"
```

### Enhancement Workflow
```bash
# Enhancement-specific setup
LABELS="enhancement,improvement"
BRANCH_PREFIX="enhancement"
PR_TEMPLATE="enhancement"

# Create enhancement branch
git checkout -b "enhancement-${ISSUE_NUMBER}-improvement-name"
```

## Directory Structure

```
project-root/
├── work/                          # Development workspace
│   ├── bug-123/                  # All bug tasks grouped together
│   │   ├── README.md             # Bug group details and checklist
│   │   ├── NOTES.md              # Development notes
│   │   ├── tests/                # Bug-specific tests
│   │   └── docs/                 # Bug documentation
│   ├── feature-124/              # All feature tasks grouped together  
│   │   ├── README.md             # Feature group details
│   │   ├── NOTES.md              # Development notes
│   │   └── tests/                # Feature-specific tests
│   └── enhancement-125/          # All enhancement tasks grouped together
├── src/                          # Main project source
├── tests/                        # Main project tests
└── docs/                         # Main project docs
```

## Complete Workflow Example

### New Bug Task Workflow
```
User: "scan the tasks"
Claude: [Shows GitHub Project tasks with types/priorities]

User: "I want to work on the authentication bug"  
Claude: "This is a 🐛 Critical bug. Setting up bug development environment..."

Claude executes:
1. Creates GitHub Issue #123 "[bug] Authentication fixes"
2. Creates branch "bug-123"  
3. Creates work/bug-123/ folder with README.md
4. Creates draft PR linked to Issue #123
5. Sets up TodoWrite session

User: [works on the code]
User: "git push"
Claude: "Pushed to bug-123. Mark PR as ready? (y/N)"
```

### Additional Bug Task (Same Type) Workflow
```  
User: "scan the tasks"
Claude: [Shows tasks including "🐛 [In Progress] Another auth bug"]

User: "I want to work on the password reset bug"
Claude: "Found existing bug Issue #123. Adding password reset bug to existing bug workflow..."

Claude executes:
1. Adds comment to existing Issue #123 about new bug task
2. Switches to existing branch "bug-123"
3. Changes to existing work/bug-123/ folder  
4. Updates README.md with new bug task checklist
5. Updates TodoWrite with both bug tasks

User: [works on multiple related bugs in same branch/folder]

User: "make production"
Claude: "Running tests... Merging PR... All bug tasks completed! ✅ Issue #123 closed!"
```

### Different Task Type Workflow
```
User: "I want to work on the new dashboard feature"
Claude: "No existing feature work found. Creating new feature Issue #124..."

Claude executes:
1. Creates separate GitHub Issue #124 "[feature] Dashboard features"
2. Creates separate branch "feature-124"
3. Creates separate work/feature-124/ folder
4. Creates separate draft PR for features

Result: 
- Bug work continues in: work/bug-123/ on branch bug-123
- Feature work starts in: work/feature-124/ on branch feature-124
```

## Integration Commands

### Workflow Automation
Claude should recognize these patterns and execute automatically:

- **"start working on issue #123"** → Resume or create workflow
- **"git push"** → Intelligent branch detection and push
- **"make production"** → Complete merge and cleanup workflow
- **"merge code"** → Same as make production
- **"create hotfix"** → Emergency bug fix workflow  
- **"clean up issue 123"** → Remove work folder and close issue

### Status Updates
Claude should automatically update:
- **GitHub Project item status** - Draft → In Progress → In Review → Done
- **GitHub Project item body** - Links to Issue, PR, branch, work folder
- **Issue status and labels** - Proper labeling and closure
- **PR status and reviewers** - Ready state and merge completion
- **Local TODO.md** - Progress tracking
- **TodoWrite session** - Sub-tasks and progress

### GitHub Project Integration Benefits

**Complete Audit Trail:**
```
GitHub Project Task → GitHub Issue → GitHub PR → Production Merge
     ↓                    ↓              ↓              ↓
Task description      Development     Code review    Deployment
& requirements        tracking        process        confirmation
```

**Real-time Updates:**
- **Task Creation** - Links added to Issue and PR immediately
- **Development Progress** - Status updated with each git push
- **Review Phase** - Project status changes to "In Review"
- **Production Complete** - Full summary with metrics and links

**Cross-Platform Visibility:**
- **Project Managers** - See progress in GitHub Projects
- **Developers** - Work in local folders with git workflow
- **Reviewers** - Access PRs directly from project tasks
- **Stakeholders** - Track completion status and deployment links

**Automated Documentation:**
- Every project task gets enriched with development details
- Issue and PR numbers are preserved for future reference
- Branch names and work folders are documented
- Completion dates and metrics are automatically recorded

## Error Handling

### Common Scenarios
```bash
# Handle merge conflicts
if git merge --no-commit main; then
    echo "✅ Clean merge possible"
else
    echo "⚠️  Merge conflicts detected. Resolve manually:"
    git status
    echo "After resolving conflicts, run: git add . && git commit"
fi

# Handle failed tests
if ! npm test; then
    echo "❌ Tests failed. Fix issues before merging."
    exit 1
fi

# Handle missing PR
if ! gh pr view "$CURRENT_BRANCH" &>/dev/null; then
    echo "📝 No PR found. Creating one..."
    gh pr create --draft --fill
fi
```

## Best Practices

### Branch Naming Convention
- **Bug**: `bugfix-123-fix-authentication-timeout`
- **Feature**: `feature-456-user-dashboard`  
- **Enhancement**: `enhancement-789-improve-performance`
- **Hotfix**: `hotfix-321-critical-security-fix`

### Commit Message Format
```
type(scope): description

- feat: new feature
- fix: bug fix
- docs: documentation
- style: formatting
- refactor: code restructuring
- test: testing
- chore: maintenance

Example: fix(auth): resolve timeout in login flow

Closes #123
```

### PR Title Format
```
Type #IssueNumber: Description

Examples:
- Fix #123: Resolve authentication timeout in login flow
- Feature #456: Add user dashboard with analytics
- Enhancement #789: Improve login page performance
```
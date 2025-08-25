# Development Workflow System

## Task-Based Development Lifecycle

When user selects a task of type **bug**, **feature**, or **enhancement** from "scan the tasks", Claude automatically sets up a complete development environment.

## Automatic Setup Workflow

### 1. Issue Creation
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
# Create feature branch based on issue
BRANCH_NAME="issue-${ISSUE_NUMBER}-$(echo 'task-title' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')"

# Create and checkout branch
git checkout -b "$BRANCH_NAME"
git push -u origin "$BRANCH_NAME"
```

### 3. Local Folder Structure
```bash
# Create work folder organized by issue number
mkdir -p "work/issue-${ISSUE_NUMBER}"
cd "work/issue-${ISSUE_NUMBER}"

# Create standard development files
touch README.md
touch NOTES.md
mkdir -p tests
mkdir -p docs

# Initialize with task information
cat > README.md << EOF
# Issue #${ISSUE_NUMBER}: Task Title

## Type: [bug/feature/enhancement]

## Description
Task description from GitHub Project

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Files Modified
- [ ] file1.js
- [ ] file2.js

## Testing
- [ ] Unit tests added
- [ ] Integration tests updated
- [ ] Manual testing completed

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

## Development Commands

### Git Push Intelligence
When user says **"git push"**, Claude should determine current context and act accordingly.

### Production/Merge Workflow
When user says **"make production"** or **"merge code"**, Claude should execute the complete merge and cleanup workflow.

## Task Type Specific Workflows

### Bug Workflow
- Create hotfix branch for critical bugs
- Add bug-specific labels and templates

### Feature Workflow  
- Create feature branch
- Set up feature documentation structure

### Enhancement Workflow
- Create enhancement branch
- Focus on improvement documentation

## Directory Structure

```
project-root/
├── work/                          # Development workspace
│   ├── issue-123/                # Issue-specific folder
│   │   ├── README.md             # Task details and checklist
│   │   ├── NOTES.md              # Development notes
│   │   ├── tests/                # Issue-specific tests
│   │   └── docs/                 # Issue documentation
│   └── issue-124/
├── src/                          # Main project source
├── tests/                        # Main project tests
└── docs/                         # Main project docs
```

## Integration Commands

### Workflow Automation
Claude should recognize these patterns and execute automatically:

- **"start working on issue #123"** → Full setup workflow
- **"git push"** → Intelligent branch detection and push
- **"make production"** → Complete merge and cleanup workflow
- **"merge code"** → Same as make production
- **"create hotfix"** → Emergency bug fix workflow
- **"clean up issue 123"** → Remove work folder and close issue

### Status Updates
Claude should automatically update:
- GitHub Project item status
- Issue status and labels
- PR status and reviewers
- Local TODO.md with progress
- TodoWrite session with sub-tasks

## Best Practices

### Branch Naming Convention
- **Bug**: `bugfix-123-fix-authentication-timeout`
- **Feature**: `feature-456-user-dashboard`  
- **Enhancement**: `enhancement-789-improve-performance`
- **Hotfix**: `hotfix-321-critical-security-fix`

### Commit Message Format
```
type(scope): description

Examples:
- fix(auth): resolve timeout in login flow
- feat(dashboard): add user analytics view
- docs(api): update authentication endpoints

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
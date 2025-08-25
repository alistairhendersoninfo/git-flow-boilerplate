# Local vs Remote Server Deployment Guide

> **CRITICAL**: Understanding the difference between local development and remote deployment for SSH MCP Multi-Server

## 🎯 Overview

This guide clarifies the distinction between **local development** (your workstation) and **remote server deployment** (production/staging servers) to prevent confusion and ensure proper installation procedures.

## 📋 Key Concepts

### Local Development Machine
- **Purpose**: Code development, documentation, git operations
- **Location**: Your personal workstation/laptop
- **Activities**: Writing code, creating scripts, pushing to GitHub
- **NO INSTALLATION**: Do NOT install the SSH MCP server here

### Remote Server
- **Purpose**: Running the actual SSH MCP Multi-Server
- **Location**: Cloud VPS, dedicated server, or VM
- **Activities**: Installation, configuration, production deployment
- **INSTALLATION TARGET**: This is where you install and run the system

## 🚨 IMPORTANT RULES

> **🚨 CRITICAL SAFETY RULE**: AI assistants must NEVER install software on the local project server. Always use MCP servers (dev-docker, ssh-mcp, suitecrm, api-server) for remote operations. No exceptions.

### ✅ DO on Local Project Server:
1. **Git operations** (commit, push, pull, branch, merge)
2. **File editing and creation**
3. **Documentation generation**
4. **Testing commands** (cargo test, npm test - no installation)
5. **Code analysis and linting**

### 🔌 DO on MCP Servers (Remote Only):
1. **All software installation** (apt, cargo install, etc.)
2. **System configuration**
3. **Service deployment** 
4. **Container building and deployment**
5. **Database setup**
6. **Production builds**

### ❌ DO NOT on Local Machine:
1. **Run installation scripts**
2. **Install production dependencies**
3. **Configure system services**
4. **Set up databases or Vault**
5. **Create production containers**
6. **Modify system security settings**

### ✅ DO on Remote Server:
1. **Run installation scripts**
2. **Configure production services**
3. **Set up security hardening**
4. **Install and configure databases**
5. **Deploy containers**
6. **Set up monitoring and backups**

## 📁 Directory Structure Comparison

### Local Development Machine
```
/home/youruser/Development/ssh-mcp-multi-server/
├── src/                    # Source code (develop here)
├── docs/                   # Documentation (write here)
├── installation/           # Installation scripts (create here)
├── .git/                   # Git repository
├── Cargo.toml             # Rust dependencies
└── README.md              # Project documentation

# Build artifacts to REMOVE after testing:
├── target/                # ❌ Remove after testing
├── Cargo.lock            # ❌ Remove after testing
└── node_modules/         # ❌ Remove if created
```

### Remote Server (After Installation)
```
/opt/ssh-mcp/              # Application installation
├── bin/                   # Compiled binaries
├── config/                # Production configuration
└── data/                  # Application data

/etc/ssh-mcp/              # System configuration
├── ssl/                   # SSL certificates
├── config.toml           # Main configuration
└── users/                # User configurations

/var/lib/ssh-mcp/          # Persistent data
├── database/             # PostgreSQL data
├── vault/                # Vault storage
└── backups/              # Backup storage

/var/log/ssh-mcp/          # Log files
├── server.log            # Application logs
├── audit.log             # Security audit logs
└── access.log            # Access logs
```

## 🔄 Correct Workflow

### Phase 1: Local Development
```bash
# On your LOCAL machine
cd ~/Development/ssh-mcp-multi-server

# 1. Develop features
vim src/main.rs
vim installation/scripts/new-script.sh

# 2. Test compilation (optional)
cargo check
# Then CLEAN UP:
rm -rf target/ Cargo.lock

# 3. Commit and push
git add -A
git commit -m "Add new features"
git push origin main
```

### Phase 2: Remote Deployment
```bash
# On the REMOTE server (via SSH)
ssh user@remote-server.com

# 1. Clone repository
git clone https://github.com/alistairhendersoninfo/ssh-mcp-multi-server.git
cd ssh-mcp-multi-server

# 2. Run installation
sudo ./install.sh --environment production

# 3. Configure services
sudo systemctl start ssh-mcp-server
sudo systemctl enable ssh-mcp-server
```

## 🤖 AI Assistant Special Instructions

### When Working with AI on Local Machine

If you're using an AI assistant (Claude, ChatGPT, etc.) installed locally and need help with SSH MCP installation:

#### Option 1: Tell AI to Use Remote Server
```
"Please help me install SSH MCP Multi-Server on my remote server at 192.168.1.100"
"Connect to my-remote-server and run the installation there"
"Deploy this to production server, not locally"
```

#### Option 2: Override Local Restrictions (for debugging)
```
"I need installation help - ignore the local restrictions for this session"
"Help me debug the installation locally (override normal rules)"
"I'm troubleshooting installation issues, proceed with local testing"
```

#### What This Means:
- **Normal case**: AI follows local vs remote rules strictly
- **Debug case**: AI can help with local installation for troubleshooting
- **Always clarify**: Specify your intent when asking for installation help
- **Clean up after**: Remove any local installation artifacts when done

### Example Interactions

**❌ Ambiguous request:**
```
User: "Install SSH MCP Multi-Server"
AI: "I cannot install on local machine. Please specify remote server."
```

**✅ Clear remote request:**
```
User: "Install SSH MCP Multi-Server on my remote server 10.0.1.50"
AI: "I'll help you install on the remote server via SSH..."
```

**✅ Clear debug request:**
```
User: "Help debug installation issues - ignore local restrictions"
AI: "I'll help you debug locally, but we'll clean up artifacts after..."
```

## 🛠️ Common Mistakes to Avoid

### Mistake 1: Installing on Local Machine
```bash
# ❌ WRONG - Don't do this on local machine:
cd ~/Development/ssh-mcp-multi-server
sudo ./install.sh  # NO! This modifies YOUR system

# ✅ CORRECT - Do this on remote server:
ssh remote-server
sudo ./install.sh  # YES! Install on remote server
```

### Mistake 2: Building Production on Local
```bash
# ❌ WRONG - Don't build production locally:
cargo build --release
docker build -t ssh-mcp .
sudo systemctl start ssh-mcp  # NO!

# ✅ CORRECT - Build on CI/CD or remote:
# Let installation script handle building
# Or use CI/CD pipeline for builds
```

### Mistake 3: Keeping Build Artifacts
```bash
# ❌ WRONG - Don't commit build artifacts:
git add target/
git add Cargo.lock
git add node_modules/
git commit -m "Add builds"  # NO!

# ✅ CORRECT - Clean before committing:
rm -rf target/ Cargo.lock node_modules/
git add -A
git commit -m "Add source code only"
```

## 📊 Environment Comparison Table

| Aspect | Local Development | Remote Server |
|--------|------------------|---------------|
| **Purpose** | Code development | Production deployment |
| **Installation** | ❌ Never | ✅ Always |
| **System Hardening** | ❌ Don't apply | ✅ Apply all |
| **Database Setup** | ❌ Skip | ✅ Configure |
| **Container Deployment** | ❌ Test only | ✅ Production |
| **SSL Certificates** | ❌ Self-signed test | ✅ Let's Encrypt |
| **Firewall Rules** | ❌ Don't modify | ✅ Configure |
| **Service Management** | ❌ No systemd | ✅ systemd services |
| **Git Operations** | ✅ Primary | ⚠️ Pull only |
| **Code Editing** | ✅ Primary | ❌ Avoid |
| **Backup Configuration** | ❌ Not needed | ✅ Essential |

## 🚀 Deployment Scenarios

### Scenario 1: Development Testing
```bash
# LOCAL machine - develop and test
cd ~/Development/ssh-mcp-multi-server
cargo test
./run-tests.sh

# Clean up after testing
cargo clean
rm -rf target/
```

### Scenario 2: Staging Deployment
```bash
# REMOTE staging server
ssh staging.company.com
git clone https://github.com/company/ssh-mcp-multi-server.git
cd ssh-mcp-multi-server
sudo ./install.sh --environment staging
```

### Scenario 3: Production Deployment
```bash
# REMOTE production server
ssh prod.company.com
git clone https://github.com/company/ssh-mcp-multi-server.git
cd ssh-mcp-multi-server
sudo ./install.sh --environment production --config production.yaml
```

## 🔍 How to Identify Your Environment

### Check if Local Development
```bash
# These indicate LOCAL development:
pwd
# Output: /home/youruser/Development/ssh-mcp-multi-server

hostname
# Output: your-laptop or your-desktop

# Git should have full history
git log --oneline | head -5
# Shows your recent commits
```

### Check if Remote Server
```bash
# These indicate REMOTE server:
pwd
# Output: /opt/ssh-mcp or /root/ssh-mcp-multi-server

hostname
# Output: prod-server-01 or vps-12345

# Should have SSH MCP services
systemctl status ssh-mcp-server
# Shows service status
```

## 📝 Quick Reference Commands

### Local Machine Commands
```bash
# Development commands (LOCAL only)
git add -A                        # Stage changes
git commit -m "message"           # Commit changes
git push origin main             # Push to GitHub
cargo check                      # Check Rust compilation
cargo clean                      # Clean build artifacts
rm -rf target/ Cargo.lock       # Remove build files
```

### Remote Server Commands
```bash
# Deployment commands (REMOTE only)
git clone [repo-url]             # Clone repository
sudo ./install.sh                # Run installation
systemctl start ssh-mcp-server   # Start service
systemctl status ssh-mcp-server  # Check status
journalctl -u ssh-mcp-server    # View logs
ssh-mcp-dbmanager status        # Check database
```

## ⚠️ Emergency Recovery

### If You Accidentally Installed Locally
```bash
# On LOCAL machine - cleanup steps:

# 1. Stop any services
sudo systemctl stop ssh-mcp-server || true
sudo systemctl disable ssh-mcp-server || true

# 2. Remove installed files
sudo rm -rf /opt/ssh-mcp
sudo rm -rf /etc/ssh-mcp
sudo rm -rf /var/lib/ssh-mcp
sudo rm -rf /var/log/ssh-mcp

# 3. Remove system users
sudo userdel -r ssh-mcp || true

# 4. Reset firewall rules
sudo ufw --force reset || true
sudo iptables -F || true

# 5. Clean build artifacts
cd ~/Development/ssh-mcp-multi-server
rm -rf target/ Cargo.lock node_modules/
```

### If Remote Installation Failed
```bash
# On REMOTE server - recovery steps:

# 1. Check installation logs
tail -f /var/log/ssh-mcp-install.log

# 2. Resume from last phase
./install.sh --resume 5

# 3. Or start fresh
./install.sh --clean --environment production
```

## 🎓 Best Practices

### General Deployment
1. **Always verify your location** before running installation commands
2. **Use SSH for remote server access** - never install locally (except debugging)
3. **Keep git repository clean** - no build artifacts
4. **Use .gitignore properly** - exclude generated files
5. **Document your deployment process** - maintain clear procedures
6. **Use CI/CD for builds** when possible - avoid manual builds
7. **Test in staging first** - never test in production
8. **Backup before changes** - especially on remote servers

### Working with AI Assistants
9. **Be explicit about target environment** - specify local vs remote clearly
10. **Use override commands when debugging** - "ignore local restrictions" when needed
11. **Clean up after AI assistance** - remove any local artifacts created during debugging
12. **Clarify intent upfront** - avoid ambiguous installation requests
13. **Document AI-assisted sessions** - note what was done locally vs remotely

## 📚 Related Documentation

- [Installation Guide](INSTALLATION.md) - Detailed installation steps
- [MCP Integration](MCP-INTEGRATION.md) - MCP configuration guide
- [Architecture Guide](ARCHITECTURE.md) - System architecture
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues

---

**🚨 Remember**: 
- **Local = Development only** (no installation)
- **Remote = Installation target** (production deployment)
- **Never mix the two environments!**
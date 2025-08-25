# AI Assistant Safety Checks

## 🚨 CRITICAL: Local Project Server Protection

**NEVER run these commands on the local project server:**

### Prohibited Local Commands
```bash
# Installation commands
sudo apt install
sudo apt-get install
make install
cargo build --release
npm install
./install.sh
./configure
cmake

# System modification commands
sudo systemctl start/stop/enable
sudo systemctl daemon-reload
sudo usermod
sudo groupadd
sudo mkdir /opt/
sudo mkdir /etc/

# Compilation commands (except for testing)
cargo build
make
gcc/clang compilation
docker build (for deployment)
```

### Safety Check Script
```bash
# Before any installation command, check:
if [[ "$PWD" == *"/Development/"* ]]; then
    echo "ERROR: Cannot install on local development server"
    echo "Use MCP servers: dev-docker, ssh-mcp, suitecrm, api-server"
    exit 1
fi
```

## ✅ Allowed Local Operations
- Git operations (add, commit, push, pull)
- File reading/editing
- Directory listing
- Testing commands (cargo test, npm test)
- Documentation generation

## 🔌 Remote Operations Only
Use MCP servers for:
- Software installation
- Service deployment
- System configuration
- Package compilation
- Container deployment

## 📋 Pre-Command Checklist
Before ANY installation command:
1. ❓ Am I on the local project server?
2. ❓ Should this run on a remote MCP server instead?
3. ❓ Is this modifying system files?
4. ❓ Is this installing software?

**If YES to any: STOP and use MCP server**
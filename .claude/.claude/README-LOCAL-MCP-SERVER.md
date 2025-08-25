# AI Assistant MCP Server Configuration

## 🔧 Overview

This document describes the MCP (Model Context Protocol) server configuration for AI assistants to connect to remote SSH servers. These are the **ONLY** servers AI assistants should use for remote operations.

## 🚨 CRITICAL SAFETY RULE

**AI assistants must NEVER install, compile, or modify software on the local project server.** 
- Use ONLY the MCP servers listed below for remote operations
- Local project server is for development and git operations ONLY
- All installation/deployment must happen on designated remote servers

## 📋 Server Configuration

### Configuration File Location
```
/home/alistair/.config/claude/mcpServers/mcp.json
```

### Current MCP Servers

| Server Name | Port | Host | User | Purpose | OS |
|-------------|------|------|------|---------|-----|
| **github-mcp-server** | - | Local | - | GitHub integration | Local |
| **dev-docker** | 3001 | 192.168.69.23 | developer | Development Docker server | Ubuntu 22.04.5 LTS |
| **ssh-mcp** | 3002 | 192.168.69.24 | developer | SSH MCP test server | Ubuntu 22.04.5 LTS |
| **suitecrm** | 3003 | 192.168.69.25 | crmadmin | SuiteCRM server | Ubuntu 22.04.5 LTS |
| **api-server** | 3004 | api.alistairhenderson.support | developer | API production server | Ubuntu 24.04.2 LTS |

## 🔑 SSH Key Configuration

### SSH Keys Location
```
/home/alistair/.ssh/
```

### Key Mappings
- **dev-docker**: `/home/alistair/.ssh/dev_docker`
- **ssh-mcp**: `/home/alistair/.ssh/dev_sshmcp`
- **suitecrm**: `/home/alistair/.ssh/crm_suitecrm` → `/home/alistair/.ssh/dev_suitecrm` (symlink)
- **api-server**: `/home/alistair/.ssh/dev_ionos`

## 🚀 Usage

### Connecting to Servers

You can ask Claude to connect to any server using these simple commands:

```
"Connect to dev-docker"     - Development Docker server
"Connect to ssh-mcp"        - SSH MCP test server  
"Connect to suitecrm"       - SuiteCRM server
"Connect to api-server"     - API production server
```

### Available Commands

Each SSH MCP server provides the `exec` tool for running shell commands:

```json
{
  "name": "exec",
  "description": "Execute a shell command on the remote SSH server and return the output",
  "inputSchema": {
    "type": "object",
    "properties": {
      "command": {
        "type": "string",
        "description": "Shell command to execute on the remote SSH server"
      }
    },
    "required": ["command"]
  }
}
```

### Example Usage

```bash
# Get system information
whoami && hostname && pwd

# Check system resources
df -h && free -h

# List files
ls -la

# Check running processes
ps aux | head -10

# Check network connectivity
ping -c 3 google.com
```

## 🛠️ Technical Details

### MCP Protocol Communication

The servers communicate using JSON-RPC 2.0 over TCP connections. Each SSH MCP server provides an `exec` tool for executing commands on the remote server.

#### Direct Command Execution via netcat

To execute commands on a remote server directly through the MCP protocol:

```bash
# List available tools
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}' | nc -w 10 localhost 3002

# Execute a command on ssh-mcp server (port 3002)
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/call", "params": {"name": "exec", "arguments": {"command": "whoami && hostname && pwd"}}}' | nc -w 10 localhost 3002

# Execute with longer timeout for complex operations
echo '{"jsonrpc": "2.0", "id": 2, "method": "tools/call", "params": {"name": "exec", "arguments": {"command": "sudo apt update && sudo apt upgrade -y"}}}' | nc -w 120 localhost 3002
```

#### MCP Server Port Mapping

- **dev-docker**: `nc localhost 3001` - Development Docker server (192.168.69.23)
- **ssh-mcp**: `nc localhost 3002` - SSH MCP test server (192.168.69.24)
- **suitecrm**: `nc localhost 3003` - SuiteCRM server (192.168.69.25)
- **api-server**: `nc localhost 3004` - API production server (api.alistairhenderson.support)

#### JSON-RPC Request Format

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "exec",
    "arguments": {
      "command": "whoami && hostname"
    }
  }
}
```

### Server Process Details

Each SSH MCP server runs as a socat process:

```bash
# Example process for port 3001
/usr/bin/socat TCP-LISTEN:3001,reuseaddr,fork EXEC:/usr/bin/node /opt/ssh-mcp-server/build/index.js --host=192.168.69.23 --user=developer --key=/home/alistair/.ssh/dev_docker --timeout=60000
```

## 📁 Complete Configuration File

```json
{
  "mcpServers": {
    "github-mcp-server": {
      "command": "bash",
      "args": ["-c", "source /opt/github-mcp-server/config/setup-env.sh && /opt/github-mcp-server/github-mcp-server stdio"],
      "env": {}
    },
    "dev-docker": {
      "command": "nc",
      "args": ["localhost", "3001"],
      "env": {}
    },
    "ssh-mcp": {
      "command": "nc", 
      "args": ["localhost", "3002"],
      "env": {}
    },
    "suitecrm": {
      "command": "nc",
      "args": ["localhost", "3003"], 
      "env": {}
    },
    "api-server": {
      "command": "nc",
      "args": ["localhost", "3004"],
      "env": {}
    }
  }
}
```

## 🔍 Troubleshooting

### Check Server Status

```bash
# Check if MCP servers are running
netstat -tlnp | grep -E ':(3001|3002|3003|3004)\s'

# Check socat processes
ps aux | grep socat | grep -v grep

# Test connectivity to a specific server
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}' | nc -w 10 localhost 3001
```

### Common Issues

1. **SSH Key Permissions**
   ```bash
   chmod 600 /home/alistair/.ssh/dev_*
   chmod 600 /home/alistair/.ssh/crm_*
   ```

2. **Missing SSH Keys**
   - Ensure all required SSH keys exist
   - Create symlinks if needed: `ln -sf source_key target_key`

3. **Port Conflicts**
   - Check if ports 3001-3004 are available
   - Restart socat processes if needed

4. **Network Connectivity**
   - Verify SSH access to remote hosts
   - Check firewall rules on remote servers

### Restart MCP Servers

If you need to restart the SSH MCP servers:

```bash
# Kill existing socat processes
pkill -f "socat.*300[1-4]"

# Restart individual servers (example for port 3001)
/usr/bin/socat TCP-LISTEN:3001,reuseaddr,fork EXEC:/usr/bin/node /opt/ssh-mcp-server/build/index.js --host=192.168.69.23 --user=developer --key=/home/alistair/.ssh/dev_docker --timeout=60000 &
```

## 🔒 Security Considerations

- SSH keys are stored with proper permissions (600)
- Connections are limited to localhost for MCP communication
- Each server uses dedicated SSH keys
- Timeout settings prevent hanging connections

## 📚 Related Documentation

- [GitHub Actions Workflow](WORKFLOW.md)
- [API Server Installation](documentation/API-SERVER-INSTALL.md)
- [GitHub Secrets Setup](GITHUB-SECRETS-SETUP.md)
- [Project Structure](PROJECT-STRUCTURE.md)

## 🤝 Usage in Projects

This MCP configuration is designed to work across multiple projects:

- **Recruitments.ninja**: Main development project
- **SuiteCRM Development**: CRM customization work
- **API Server Management**: Production server maintenance
- **Docker Development**: Containerized development environment

## 📝 Notes

- Configuration file must be valid JSON
- Server names should be descriptive and easy to remember
- SSH keys must exist and have correct permissions
- All servers should be tested after configuration changes

---

**Last Updated**: August 23, 2025  
**Configuration Version**: 1.0  
**Compatible with**: Claude Desktop with MCP support
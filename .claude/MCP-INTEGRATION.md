# SSH MCP Multi-Server - IDE/CLI Integration Guide

> **Complete guide for integrating SSH MCP Multi-Server with Claude Desktop, CLI tools, and other AI assistants**

## 🎯 Overview

This guide covers all methods to integrate SSH MCP Multi-Server with various AI assistants and development environments, including Claude Desktop, Claude CLI, and other MCP-compatible tools.

## 📋 Table of Contents

1. [Claude Desktop Integration](#claude-desktop-integration)
2. [Claude CLI Integration](#claude-cli-integration)
3. [Direct MCP Protocol Usage](#direct-mcp-protocol-usage)
4. [VS Code Integration](#vs-code-integration)
5. [Terminal/Shell Integration](#terminalshell-integration)
6. [Authentication Methods](#authentication-methods)
7. [Troubleshooting](#troubleshooting)

## 🖥️ Claude Desktop Integration

### Configuration File Location

**macOS:**
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

**Windows:**
```
%APPDATA%\Claude\claude_desktop_config.json
```

**Linux:**
```
~/.config/claude-desktop/claude_desktop_config.json
```

### Basic Configuration

```json
{
  "mcpServers": {
    "ssh-mcp-multi-server": {
      "command": "ssh-mcp-client",
      "args": [
        "--server", "https://your-server.com:8443",
        "--api-key", "ak_live_your_api_key_here"
      ]
    }
  }
}
```

### Advanced Configuration with Environment Variables

```json
{
  "mcpServers": {
    "ssh-mcp-multi-server": {
      "command": "ssh-mcp-client",
      "args": [
        "--server", "https://your-server.com:8443",
        "--api-key", "${SSH_MCP_API_KEY}"
      ],
      "env": {
        "SSH_MCP_API_KEY": "ak_live_your_api_key_here",
        "SSH_MCP_TIMEOUT": "60",
        "SSH_MCP_DEBUG": "false"
      }
    }
  }
}
```

### Multi-Environment Configuration

```json
{
  "mcpServers": {
    "ssh-mcp-production": {
      "command": "ssh-mcp-client",
      "args": [
        "--server", "https://prod.company.com:8443",
        "--api-key", "${PROD_SSH_MCP_API_KEY}",
        "--env", "production"
      ]
    },
    "ssh-mcp-staging": {
      "command": "ssh-mcp-client", 
      "args": [
        "--server", "https://staging.company.com:8443",
        "--api-key", "${STAGING_SSH_MCP_API_KEY}",
        "--env", "staging"
      ]
    },
    "ssh-mcp-development": {
      "command": "ssh-mcp-client",
      "args": [
        "--server", "https://dev.company.com:8443",
        "--api-key", "${DEV_SSH_MCP_API_KEY}",
        "--env", "development"
      ]
    }
  }
}
```

### Usage Examples in Claude Desktop

Once configured, you can use natural language to manage your servers:

```
"Check disk usage on web-server-01"
"Restart nginx on prod-web-01" 
"Show me the last 100 lines of /var/log/nginx/error.log on web-server-01"
"Upload my local deployment script to prod-web-01:/opt/scripts/"
"List all running Docker containers on docker-host-01"
"Check system memory usage on all production servers"
```

## 💻 Claude CLI Integration

### Installation

First, install Claude CLI:

```bash
# macOS
brew install anthropics/claude/claude

# Windows (using Scoop)
scoop install claude

# Linux (using curl)
curl -fsSL https://claude.ai/cli/install.sh | sh
```

### Configuration

Create a configuration file at `~/.claude/config.json`:

```json
{
  "mcpServers": {
    "ssh-mcp": {
      "command": "ssh-mcp-client",
      "args": [
        "--server", "https://your-server.com:8443",
        "--api-key", "ak_live_your_api_key_here"
      ]
    }
  }
}
```

### Usage Examples

```bash
# Start a conversation with MCP access
claude chat --enable-mcp ssh-mcp

# One-shot command
claude ask "Check disk usage on web-server-01" --enable-mcp ssh-mcp

# Interactive session
claude session start --enable-mcp ssh-mcp
```

### Batch Operations

```bash
# Create a script for daily server checks
cat > daily-check.txt << EOF
Check disk usage on all servers
Check memory usage on all servers  
Show any failed systemd services
Check Docker container health
Verify SSL certificate expiration dates
EOF

claude batch --file daily-check.txt --enable-mcp ssh-mcp
```

## 🔌 Direct MCP Protocol Usage

### Using netcat for Direct Protocol Access

```bash
# List available tools
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}' | \
  nc your-server.com 8443

# Execute a command
echo '{"jsonrpc": "2.0", "id": 2, "method": "tools/call", "params": {"name": "execute_command", "arguments": {"server": "web-01", "command": "uptime"}}}' | \
  nc your-server.com 8443
```

### Python MCP Client

```python
import json
import socket
import ssl

class SSHMCPClient:
    def __init__(self, host, port, api_key):
        self.host = host
        self.port = port
        self.api_key = api_key
        self.request_id = 1
    
    def connect(self):
        context = ssl.create_default_context()
        sock = socket.create_connection((self.host, self.port))
        self.conn = context.wrap_socket(sock, server_hostname=self.host)
    
    def call_tool(self, tool_name, arguments):
        request = {
            "jsonrpc": "2.0",
            "id": self.request_id,
            "method": "tools/call",
            "params": {
                "name": tool_name,
                "arguments": arguments
            },
            "headers": {
                "Authorization": f"Bearer {self.api_key}"
            }
        }
        
        self.conn.send(json.dumps(request).encode() + b'\n')
        response = self.conn.recv(4096).decode()
        self.request_id += 1
        
        return json.loads(response)
    
    def execute_command(self, server, command, username=None):
        args = {"server": server, "command": command}
        if username:
            args["username"] = username
        
        return self.call_tool("execute_command", args)
    
    def list_servers(self):
        return self.call_tool("list_servers", {})

# Usage
client = SSHMCPClient("your-server.com", 8443, "ak_live_your_api_key")
client.connect()

result = client.execute_command("web-01", "df -h")
print(result)
```

### Node.js MCP Client

```javascript
const net = require('net');
const tls = require('tls');

class SSHMCPClient {
    constructor(host, port, apiKey) {
        this.host = host;
        this.port = port;
        this.apiKey = apiKey;
        this.requestId = 1;
    }
    
    connect() {
        return new Promise((resolve, reject) => {
            this.conn = tls.connect(this.port, this.host, {
                rejectUnauthorized: false // For self-signed certificates
            }, resolve);
            this.conn.on('error', reject);
        });
    }
    
    async callTool(toolName, arguments) {
        const request = {
            jsonrpc: "2.0",
            id: this.requestId++,
            method: "tools/call",
            params: {
                name: toolName,
                arguments: arguments
            },
            headers: {
                Authorization: `Bearer ${this.apiKey}`
            }
        };
        
        return new Promise((resolve, reject) => {
            this.conn.write(JSON.stringify(request) + '\n');
            
            this.conn.once('data', (data) => {
                try {
                    const response = JSON.parse(data.toString());
                    resolve(response);
                } catch (err) {
                    reject(err);
                }
            });
        });
    }
    
    async executeCommand(server, command, username = null) {
        const args = { server, command };
        if (username) args.username = username;
        
        return await this.callTool("execute_command", args);
    }
    
    async listServers() {
        return await this.callTool("list_servers", {});
    }
}

// Usage
(async () => {
    const client = new SSHMCPClient('your-server.com', 8443, 'ak_live_your_api_key');
    await client.connect();
    
    const result = await client.executeCommand('web-01', 'uptime');
    console.log(result);
})();
```

## 🔧 VS Code Integration

### Extension Configuration

Install the MCP extension for VS Code and configure it in `settings.json`:

```json
{
    "mcp.servers": {
        "ssh-mcp-multi-server": {
            "command": "ssh-mcp-client",
            "args": [
                "--server", "https://your-server.com:8443",
                "--api-key", "ak_live_your_api_key_here"
            ]
        }
    }
}
```

### Custom VS Code Tasks

Create tasks in `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Deploy to Production",
            "type": "shell",
            "command": "ssh-mcp-client",
            "args": [
                "--server", "https://prod.company.com:8443",
                "--api-key", "${env:PROD_SSH_MCP_API_KEY}",
                "--execute", "deploy_application.sh"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new"
            }
        },
        {
            "label": "Check Server Status",
            "type": "shell", 
            "command": "ssh-mcp-client",
            "args": [
                "--server", "https://prod.company.com:8443",
                "--api-key", "${env:PROD_SSH_MCP_API_KEY}",
                "--command", "systemctl status nginx docker postgresql"
            ]
        }
    ]
}
```

## 🖥️ Terminal/Shell Integration

### Bash Completion

Add to your `~/.bashrc`:

```bash
# SSH MCP Multi-Server completion
_ssh_mcp_completion() {
    local cur prev opts servers
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Get server list from MCP server
    servers=$(ssh-mcp-client --list-servers 2>/dev/null | jq -r '.servers[].name')
    opts="--server --api-key --command --upload --download --list-servers --help"
    
    case "${prev}" in
        --server)
            COMPREPLY=( $(compgen -W "${servers}" -- ${cur}) )
            return 0
            ;;
        --command|--upload|--download)
            # No completion for these
            return 0
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
    esac
}
complete -F _ssh_mcp_completion ssh-mcp-client
```

### Shell Aliases

Add convenient aliases to your shell configuration:

```bash
# SSH MCP aliases
alias smc='ssh-mcp-client --server https://your-server.com:8443 --api-key ak_live_your_key'
alias smc-prod='ssh-mcp-client --server https://prod.company.com:8443 --api-key $PROD_API_KEY'
alias smc-dev='ssh-mcp-client --server https://dev.company.com:8443 --api-key $DEV_API_KEY'

# Quick server commands
alias check-web='smc --command "df -h && free -h && uptime" --server web-01'
alias check-db='smc --command "pg_stat_activity && pg_stat_database" --server db-01'
alias deploy='smc --upload ./deploy.sh --server prod-web-01 && smc --command "./deploy.sh" --server prod-web-01'
```

### Advanced Shell Functions

```bash
# Multi-server command execution
mcp_multi_exec() {
    local command="$1"
    shift
    local servers=("$@")
    
    for server in "${servers[@]}"; do
        echo "=== Executing on $server ==="
        ssh-mcp-client --server https://your-server.com:8443 \
                       --api-key ak_live_your_key \
                       --command "$command" \
                       --server "$server"
        echo
    done
}

# Usage: mcp_multi_exec "uptime" web-01 web-02 db-01

# Interactive server selection
mcp_interactive() {
    local servers=($(ssh-mcp-client --list-servers | jq -r '.servers[].name'))
    
    echo "Available servers:"
    select server in "${servers[@]}"; do
        if [[ -n $server ]]; then
            echo "Selected: $server"
            echo "Command: "
            read -r command
            ssh-mcp-client --server https://your-server.com:8443 \
                           --api-key ak_live_your_key \
                           --command "$command" \
                           --server "$server"
            break
        fi
    done
}
```

## 🔐 Authentication Methods

### API Key Authentication

**Environment Variables:**
```bash
export SSH_MCP_API_KEY="ak_live_your_api_key_here"
export SSH_MCP_SERVER="https://your-server.com:8443"

ssh-mcp-client --command "uptime" --server web-01
```

**Configuration File (`~/.ssh-mcp/config.json`):**
```json
{
    "default_server": "https://your-server.com:8443",
    "api_key": "ak_live_your_api_key_here",
    "timeout": 60,
    "verify_ssl": true
}
```

### TOTP Authentication (for Admin Operations)

```bash
# Generate new API key with TOTP
ssh-mcp-client --auth-totp 123456 --generate-api-key

# Admin operations requiring TOTP
ssh-mcp-client --auth-totp 789012 --admin-command "create_user john.doe"
```

### Certificate-based Authentication

```bash
# Using client certificates
ssh-mcp-client --cert ~/.ssh-mcp/client.crt \
               --key ~/.ssh-mcp/client.key \
               --server https://your-server.com:8443 \
               --command "uptime" \
               --server web-01
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Connection Refused
```bash
# Check server status
curl -k https://your-server.com:8443/health

# Check firewall
telnet your-server.com 8443

# Verify SSL certificate
openssl s_client -connect your-server.com:8443
```

#### 2. Authentication Failed
```bash
# Verify API key format
echo "ak_live_your_api_key_here" | wc -c  # Should be correct length

# Test API key directly
curl -k -H "Authorization: Bearer ak_live_your_api_key_here" \
     https://your-server.com:8443/api/v1/tools
```

#### 3. SSL Certificate Issues
```bash
# For self-signed certificates
ssh-mcp-client --insecure --server https://your-server.com:8443 --command "uptime"

# Add certificate to trust store (Linux)
sudo cp server.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

### Debug Mode

Enable verbose logging:

```bash
# Environment variable
export SSH_MCP_DEBUG=true

# Command line flag
ssh-mcp-client --debug --server https://your-server.com:8443 --command "uptime"

# Log file
ssh-mcp-client --log-file /tmp/mcp-debug.log --server https://your-server.com:8443 --command "uptime"
```

### Health Checks

```bash
# Server health
curl -k https://your-server.com:8443/health

# MCP protocol test
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}' | \
  nc your-server.com 8443

# Full connection test
ssh-mcp-client --test-connection --server https://your-server.com:8443
```

## 📚 Additional Resources

### Documentation Links
- [Main README](../README.md) - Complete project overview
- [API Reference](API.md) - Detailed API documentation  
- [Security Guide](SECURITY.md) - Security best practices
- [Operations Manual](OPERATIONS.md) - Day-to-day operations

### Example Configurations
- [Production Setup](../installation/config/production.yaml)
- [Development Setup](../installation/config/development.yaml)
- [Local MCP Server](../README-LOCAL-MCP-SERVER.md)

### Community
- [GitHub Issues](https://github.com/alistairhendersoninfo/ssh-mcp-multi-server/issues)
- [Discussions](https://github.com/alistairhendersoninfo/ssh-mcp-multi-server/discussions)
- [Security Reports](mailto:security@ssh-mcp.com)

---

**🛡️ Security Note:** Always use secure connections (HTTPS) and strong API keys in production environments. Never commit API keys to version control.
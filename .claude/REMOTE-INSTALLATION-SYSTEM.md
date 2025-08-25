# Remote Installation System Documentation

## 🚀 Overview

This document describes the comprehensive remote installation system for deploying projects and third-party software to remote servers via MCP SSH connections. The system supports two main workflows:

1. **Project Installation**: `install remotely` - Deploy this project to a remote server
2. **Software Installation**: `remote install [software]` - Install third-party software on a remote server

## 📋 System Requirements

### Prerequisites
- Remote server accessible via MCP SSH connection
- User account with sudo access (no password required)
- Git installed on remote server (will be installed if missing)
- Internet connectivity on remote server

### MCP Server Configuration
The system requires configured MCP SSH servers as documented in `.claude/README-LOCAL-MCP-SERVER.md`:
- **dev-docker**: Port 3001 (192.168.69.23)
- **ssh-mcp**: Port 3002 (192.168.69.24) 
- **suitecrm**: Port 3003 (192.168.69.25)
- **api-server**: Port 3004 (api.alistairhenderson.support)

## 🔄 Installation Workflows

### Project Installation Workflow

```mermaid
flowchart TD
    A[User: 'install remotely'] --> B[Prompt: Which MCP server?]
    B --> C[User: e.g. 'ssh-mcp']
    C --> D[Prompt: Which user? Must have sudo access no password]
    D --> E[User: e.g. 'developer']
    E --> F[Git push to origin]
    F --> G[Connect to remote server]
    G --> H[Install git if missing]
    H --> I[Create /opt directory if missing]
    I --> J[Clone project to /opt/[project-name]]
    J --> K[Check for install instructions]
    K --> L{Install docs found?}
    L -->|Yes| M[Follow README/INSTALL.md instructions]
    L -->|No| N[Create basic installation]
    M --> O[Test installation]
    N --> O
    O --> P{Installation successful?}
    P -->|No| Q[Debug and fix issues]
    Q --> O
    P -->|Yes| R[Create REMOTE-INSTALL-GUIDE.md]
    R --> S[Create new branch: remote-install-docs]
    S --> T[Apply changes to local project]
    T --> U[Create Pull Request]
    U --> V[Document lessons learned]
    V --> W[End: Installation Complete]
```

### Third-Party Software Installation Workflow

```mermaid
flowchart TD
    A[User: 'remote install [software]'] --> B[Prompt: Which MCP server?]
    B --> C[User: e.g. 'ssh-mcp']
    C --> D[Prompt: Which user? Must have sudo access no password]
    D --> E[User: e.g. 'developer']
    E --> F[Connect to remote server]
    F --> G[Research software installation requirements]
    G --> H[Check vendor installation instructions]
    H --> I{Use /opt?}
    I -->|Instructions specify /opt| J[Install to /opt/[software]]
    I -->|Follow vendor path| K[Install to vendor-specified path]
    J --> L[Follow installation steps]
    K --> L
    L --> M[Test installation]
    M --> N{Installation successful?}
    N -->|No| O[Debug and fix issues]
    O --> M
    N -->|Yes| P[Create [SOFTWARE]-INSTALL-INSTRUCTIONS.md]
    P --> Q[Document complete process]
    Q --> R[End: Software Installed]
```

## 📖 Command Usage

### Install Remotely (Project Installation)

**Command**: `install remotely`

**Workflow**:
1. Claude prompts: "Which MCP server should I use for installation?"
2. User responds: e.g., "ssh-mcp"
3. Claude prompts: "Which user should I use? (Must have sudo access with no password required)"
4. User responds: e.g., "developer"
5. Claude performs git push to origin
6. Claude connects to specified MCP server
7. Installation process begins following the project workflow

### Remote Install Software

**Command**: `remote install [software-name]`

**Example**: `remote install SuiteCRM`

**Workflow**:
1. Claude prompts: "Which MCP server should I use for SuiteCRM installation?"
2. User responds: e.g., "suitecrm"
3. Claude prompts: "Which user should I use? (Must have sudo access with no password required)"
4. User responds: e.g., "crmadmin"
5. Claude connects to specified MCP server
6. Software installation process begins following vendor instructions

## 📁 Directory Structure

### Project Installation Structure
```
/opt/
└── [project-name]/          # Main project directory
    ├── src/                 # Source code
    ├── docs/                # Documentation
    ├── README.md            # Project readme
    ├── INSTALL.md           # Installation instructions (if exists)
    ├── Cargo.toml           # Rust project (if applicable)
    ├── package.json         # Node.js project (if applicable)
    └── [other project files]
```

### Generated Documentation Structure
```
project-root/
├── docs/
│   ├── REMOTE-INSTALL-GUIDE.md           # Generated for project installs
│   └── [SOFTWARE]-INSTALL-INSTRUCTIONS.md # Generated for software installs
└── [existing project files]
```

## 📝 Documentation Templates

### REMOTE-INSTALL-GUIDE.md Template

This document is generated after successful project installation and includes:
- Server details and user account used
- Prerequisites and dependencies installed
- Step-by-step installation process
- Configuration changes made
- Issues encountered and solutions
- Testing procedures performed
- Post-installation verification steps

### [SOFTWARE]-INSTALL-INSTRUCTIONS.md Template

This document is generated after successful third-party software installation and includes:
- Software version installed
- Server details and installation path
- Prerequisites and system requirements
- Complete installation process
- Configuration files modified
- Security considerations
- Testing and verification steps
- Troubleshooting common issues

## 🔧 Installation Process Details

### Phase 1: Preparation
1. **Git Push**: Ensure latest code is pushed to origin
2. **Server Connection**: Establish MCP connection to target server
3. **User Verification**: Confirm user has sudo access without password
4. **System Check**: Verify system requirements and compatibility

### Phase 2: Environment Setup
1. **Git Installation**: Install git if not present
2. **Directory Creation**: Create `/opt` directory structure
3. **Permission Setup**: Set appropriate directory permissions
4. **Dependency Check**: Identify and install required dependencies

### Phase 3: Project/Software Installation
1. **Code Retrieval**: Clone project or download software
2. **Instruction Analysis**: Parse README/INSTALL.md or vendor docs
3. **Installation Execution**: Follow installation procedures
4. **Configuration**: Apply necessary configuration changes
5. **Service Setup**: Configure systemd services if required

### Phase 4: Verification and Documentation
1. **Installation Testing**: Verify successful installation
2. **Functionality Check**: Test core functionality
3. **Documentation Creation**: Generate installation guide
4. **Local Integration**: Apply changes to local codebase
5. **Branch and PR**: Create branch and pull request

## 🚨 Error Handling

### Common Issues and Solutions

1. **SSH Connection Failures**
   - Verify MCP server is running
   - Check SSH key permissions
   - Validate server connectivity

2. **Permission Issues**
   - Confirm user has sudo access
   - Check directory permissions
   - Verify no password required for sudo

3. **Git Issues**
   - Install git if missing
   - Configure git user if needed
   - Handle authentication if required

4. **Installation Failures**
   - Check system dependencies
   - Verify internet connectivity
   - Review error logs for specific issues

5. **Service Configuration**
   - Check port availability
   - Verify firewall settings
   - Test service startup

## 🔒 Security Considerations

### Best Practices
- Always use sudo users with proper privileges
- Verify SSH key security and permissions
- Follow principle of least privilege
- Document all security-related changes
- Test installations in development first

### Security Checklist
- [ ] User account has appropriate sudo privileges
- [ ] SSH keys are properly secured
- [ ] Installation directory permissions are correct
- [ ] Services run with appropriate user privileges
- [ ] Firewall rules are configured if needed
- [ ] Security updates are applied

## 🎯 Success Criteria

### Project Installation Success
- [ ] Project successfully cloned to `/opt/[project-name]`
- [ ] All dependencies installed and configured
- [ ] Application builds and runs successfully
- [ ] All tests pass (if applicable)
- [ ] Services start automatically (if applicable)
- [ ] Documentation generated and complete
- [ ] Changes integrated into local codebase
- [ ] Pull request created with all modifications

### Software Installation Success
- [ ] Software installed to appropriate location
- [ ] All dependencies and prerequisites met
- [ ] Configuration properly applied
- [ ] Service running and accessible
- [ ] Basic functionality verified
- [ ] Installation documentation complete
- [ ] Security considerations addressed

## 🔄 Branch and PR Management

### Branch Naming Convention
- **Project Installs**: `remote-install-docs-[server-name]-[date]`
- **Software Installs**: `software-install-[software-name]-[server-name]-[date]`

### Pull Request Requirements
- Descriptive title indicating what was installed where
- Complete installation documentation
- Any code changes needed for remote deployment
- Testing notes and verification steps
- Screenshots or logs if helpful

## 📊 Monitoring and Maintenance

### Post-Installation Monitoring
- Service health checks
- Log monitoring for errors
- Performance baseline establishment
- Security scan execution
- Backup verification

### Maintenance Procedures
- Regular security updates
- Service restart procedures
- Log rotation configuration
- Backup and recovery testing
- Documentation updates

---

## 🤝 Usage Examples

### Example 1: Installing SSH MCP Multi-Server
```
User: install remotely
Claude: Which MCP server should I use for installation?
User: ssh-mcp
Claude: Which user should I use? (Must have sudo access with no password required)
User: developer
Claude: [Performs installation following project workflow]
```

### Example 2: Installing SuiteCRM
```
User: remote install SuiteCRM
Claude: Which MCP server should I use for SuiteCRM installation?
User: suitecrm
Claude: Which user should I use? (Must have sudo access with no password required)
User: crmadmin
Claude: [Performs SuiteCRM installation following vendor guidelines]
```

## 📚 Related Documentation
- [Local MCP Server Configuration](.claude/README-LOCAL-MCP-SERVER.md)
- [Project CLAUDE.md](CLAUDE.md)
- [Installation TODO](.claude/TODO.md)

---

**Last Updated**: August 24, 2025  
**Version**: 1.0  
**Status**: Documentation Complete

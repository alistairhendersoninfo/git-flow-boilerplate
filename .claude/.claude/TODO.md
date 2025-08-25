# SSH MCP Multi-Server Installation & Setup TODO

> **Note**: This file contains sensitive implementation details and should not be committed to git.

## 🚀 Master Installation Script Requirements

### Phase 1: System Hardening & Base Setup

#### 1.1 Operating System Hardening
- [ ] **SELinux Configuration**
  - Enable SELinux in enforcing mode
  - Create custom SSH MCP policies (`infrastructure/selinux/ssh-mcp.te`)
  - Configure contexts for all application directories
  - Test policy enforcement before production deployment

- [ ] **Firewall & Network Security**
  - Configure nftables/iptables rules (only HTTPS/8443 exposed)
  - Block all SSH access except from management network
  - Configure fail2ban for API endpoint protection
  - Implement rate limiting at network level

- [ ] **File System Security**
  - Set up encrypted filesystems for sensitive data
  - Configure immutable system directories where possible
  - Implement file integrity monitoring (AIDE/OSSEC)
  - Set proper file permissions and ACLs

- [ ] **User & Access Control**
  - Create `ssh-mcp` system user with minimal privileges
  - Configure sudo policies for admin operations
  - Set up restricted shells for application users
  - Implement password policies and account lockout

#### 1.2 Container Runtime Setup
- [ ] **containerd Installation**
  - Install containerd (not Docker) for security
  - Configure rootless containers where possible
  - Set up container image scanning
  - Configure resource limits and cgroup constraints

- [ ] **Nomad Installation**
  - Install HashiCorp Nomad cluster (single node initially)
  - Configure Nomad with Vault integration
  - Set up mTLS between Nomad and Vault
  - Configure job constraints and resource allocation

#### 1.3 Firejail Sandboxing
- [ ] **Application Sandboxing**
  - Create custom firejail profiles for each service
  - Test sandbox escapes and privilege escalation
  - Configure seccomp filters for system call restrictions
  - Implement network namespace isolation

### Phase 2: Core Infrastructure Deployment

#### 2.1 HashiCorp Vault Setup
- [ ] **Vault Installation & Configuration**
  - Install Vault with file storage backend (single node)
  - Initialize Vault with master keys (stored securely offline)
  - Configure authentication methods (AppRole for services)
  - Set up periodic key rotation policies
  - Create backup and recovery procedures

- [ ] **Secret Management Policies**
  - Define policies for SSH key storage
  - Configure certificate authority for mTLS
  - Set up database credential rotation
  - Implement secret versioning and rollback

#### 2.2 PostgreSQL Database
- [ ] **Database Installation**
  - Install PostgreSQL with encryption at rest
  - Configure connection limits and performance tuning
  - Set up Unix socket communication (no network access)
  - Implement automatic vacuum and maintenance

- [ ] **Database Schema & Security**
  - Create encrypted database schemas
  - Set up row-level security policies
  - Configure audit logging for all database operations
  - Implement automated backup and point-in-time recovery

#### 2.3 Traefik Reverse Proxy
- [ ] **Traefik Setup**
  - Configure Traefik with Let's Encrypt integration
  - Set up security headers and HSTS
  - Implement rate limiting and IP whitelisting
  - Configure access logs and monitoring

### Phase 3: SSH MCP Application Deployment

#### 3.1 Container Image Building
- [ ] **Production Container Images**
  - Build distroless/scratch-based images
  - Implement multi-stage builds for minimal attack surface
  - Configure container image signing and verification
  - Set up automated security scanning in CI/CD

- [ ] **Development vs Production Builds**
  - Git branch-based build differentiation
  - Remove SSH access capabilities in main branch builds
  - Configure feature flags for development tools
  - Implement automated testing before container builds

#### 3.2 Application Configuration
- [ ] **Configuration Management**
  - Externalize all configuration to Vault/environment
  - Implement configuration validation and schema checking
  - Set up configuration change auditing
  - Configure hot-reloading where safe

#### 3.3 Service Mesh & Communication
- [ ] **Inter-Service Communication**
  - Set up mTLS between all services
  - Configure service discovery through Nomad/Consul
  - Implement circuit breakers and retry policies
  - Set up distributed tracing and monitoring

### Phase 4: User Management System

#### 4.1 Linux User Provisioning
- [ ] **User Creation Service**
  - Implement automated Linux user creation
  - Configure SSH key generation and distribution
  - Set up restricted shell environments
  - Implement user quota and resource limits

- [ ] **SSH Key Management**
  - Secure key generation (Ed25519)
  - Temporary key storage in Vault
  - Secure key distribution mechanisms
  - Key rotation and revocation procedures

#### 4.2 TOTP Authentication System
- [ ] **TOTP Implementation**
  - Integrate TOTP library for multi-factor authentication
  - Implement QR code generation for initial setup
  - Create backup code generation and recovery
  - Set up TOTP secret rotation capabilities

#### 4.3 API Key Lifecycle Management
- [ ] **API Key Operations**
  - User self-service API key regeneration
  - Admin-controlled API key management
  - Automatic key expiration and rotation
  - Comprehensive audit trail for all key operations

### Phase 5: Security & Monitoring

#### 5.1 Backup & Recovery System
- [ ] **Encrypted Backup Solution**
  - Implement nightly encrypted backups to S3-compatible storage
  - Set up weekly key rotation for backup encryption
  - Configure automated backup verification and integrity checking
  - Create disaster recovery runbooks and testing procedures

#### 5.2 Monitoring & Alerting
- [ ] **Operational Monitoring**
  - Set up log aggregation and analysis
  - Configure metrics collection (Prometheus/similar)
  - Implement security event monitoring and alerting
  - Create operational dashboards and runbooks

#### 5.3 Security Auditing
- [ ] **Audit & Compliance**
  - Implement comprehensive audit logging for all operations
  - Set up automated security scanning and vulnerability assessment
  - Configure compliance reporting and evidence collection
  - Create security incident response procedures

### Phase 6: Installation Script Implementation

#### 6.1 Master Install Script (`install.sh`)
```bash
#!/bin/bash
# SSH MCP Multi-Server Installation Script
# Usage: ./install.sh [--dev|--prod] [--config config.yaml]

# Installation phases:
# 1. System validation and prerequisites
# 2. Security hardening and OS configuration  
# 3. Container runtime and orchestration setup
# 4. Core infrastructure deployment (Vault, PostgreSQL, Traefik)
# 5. Application deployment and configuration
# 6. User management system setup
# 7. Backup and monitoring configuration
# 8. Security validation and testing
```

- [ ] **Installation Features**
  - Idempotent installation (safe to run multiple times)
  - Rollback capabilities if installation fails
  - Configuration validation before deployment
  - Health checks after each phase
  - Comprehensive logging of all installation steps

#### 6.2 Configuration Management
- [ ] **Installation Configuration**
  - YAML-based configuration file for all settings
  - Environment-specific configurations (dev/staging/prod)
  - Secret management during installation
  - Configuration templates with safe defaults

#### 6.3 Post-Installation Validation
- [ ] **System Verification**
  - End-to-end connectivity testing
  - Security configuration validation
  - Performance baseline establishment
  - Documentation of installed components and versions

### Phase 7: Documentation & Operations

#### 7.1 Operational Documentation
- [ ] **Operations Runbooks**
  - Installation and deployment procedures
  - Backup and recovery procedures
  - Security incident response
  - Routine maintenance and updates
  - Troubleshooting guides

#### 7.2 User Documentation
- [ ] **User Guides**
  - Admin user creation and management
  - End-user TOTP setup and usage
  - API key management procedures
  - SSH access and security guidelines

#### 7.3 Developer Documentation
- [ ] **Development Setup**
  - Local development environment setup
  - Container build and testing procedures
  - Security testing and validation
  - Contribution guidelines and code review process

## 🎯 Installation Script Structure

```
installation/
├── install.sh                    # Master installation script
├── config/
│   ├── production.yaml          # Production configuration template
│   ├── development.yaml         # Development configuration template
│   └── validation.schema.json   # Configuration validation schema
├── scripts/
│   ├── 01-system-hardening.sh  # OS and security hardening
│   ├── 02-container-setup.sh   # Container runtime installation
│   ├── 03-vault-setup.sh       # Vault installation and configuration
│   ├── 04-database-setup.sh    # PostgreSQL installation and setup
│   ├── 05-app-deployment.sh    # Application container deployment
│   ├── 06-user-mgmt-setup.sh   # User management system setup
│   ├── 07-backup-config.sh     # Backup system configuration
│   └── 08-monitoring-setup.sh  # Monitoring and alerting setup
├── templates/
│   ├── nomad-jobs/             # Nomad job templates
│   ├── vault-policies/         # Vault policy templates  
│   ├── selinux-policies/       # SELinux policy templates
│   └── systemd-services/       # Systemd service templates
├── validation/
│   ├── security-tests.sh       # Security configuration validation
│   ├── connectivity-tests.sh   # Network and service connectivity
│   └── performance-tests.sh    # Basic performance validation
└── docs/
    ├── INSTALL.md              # Installation guide
    ├── OPERATIONS.md           # Operations runbook
    └── TROUBLESHOOTING.md      # Troubleshooting guide
```

## 🔐 Security Checklist for Installation

### Pre-Installation Security Validation
- [ ] Verify system meets minimum security requirements
- [ ] Check for existing security tools and configurations
- [ ] Validate network segmentation and firewall rules
- [ ] Ensure secure boot and hardware security features are enabled

### During Installation Security Steps
- [ ] All secrets generated cryptographically secure
- [ ] No secrets logged or stored in plain text
- [ ] All network communications encrypted (mTLS where possible)
- [ ] Principle of least privilege applied to all accounts and services
- [ ] All containers run as non-root users
- [ ] File system permissions set to most restrictive possible

### Post-Installation Security Validation
- [ ] Penetration testing of exposed endpoints
- [ ] Vulnerability scanning of all installed components
- [ ] Security configuration compliance checking
- [ ] Backup and recovery testing with encrypted data
- [ ] Incident response plan testing

## 📋 Installation Prerequisites

### Hardware Requirements
- [ ] **Minimum Specifications**
  - CPU: 4 cores (8 recommended)
  - RAM: 8GB (16GB recommended)  
  - Storage: 100GB SSD (encrypted)
  - Network: Reliable internet connection for updates and backups

### Software Requirements
- [ ] **Operating System**
  - RHEL 9.x / Rocky Linux 9.x / AlmaLinux 9.x (preferred)
  - Ubuntu 22.04 LTS (alternative)
  - Fresh installation recommended
  - All security updates applied

### Network Requirements
- [ ] **Network Configuration**
  - Static IP address assigned
  - DNS resolution working correctly
  - NTP synchronization configured
  - Access to package repositories and container registries
  - Outbound HTTPS access for Let's Encrypt and updates

### Administrative Access
- [ ] **Installation Account**
  - sudo/root access for installation
  - SSH key-based authentication (no passwords)
  - Secure terminal access to the installation system
  - Backup communication method in case of SSH issues

## ⚠️ Critical Security Notes

1. **Master Keys**: Vault unseal keys must be stored offline and split among multiple trusted administrators
2. **Installation Secrets**: All temporary installation secrets must be securely deleted after installation
3. **Network Access**: SSH access should be completely disabled after installation (except for emergency management network)
4. **Backup Encryption**: Backup encryption keys must be rotated and managed separately from the main system
5. **Emergency Access**: Emergency break-glass procedures must be documented and tested before production deployment

## 🎯 Success Criteria

### Installation Success Indicators
- [ ] All services running and healthy
- [ ] Security scans show no critical vulnerabilities
- [ ] End-to-end user workflow functional (create user → TOTP setup → API access)
- [ ] Backup system operational and tested
- [ ] Monitoring and alerting functional
- [ ] Documentation complete and accessible

### Post-Installation Validation
- [ ] Performance baseline established
- [ ] Security configuration compliance verified
- [ ] Recovery procedures tested
- [ ] Administrative procedures documented and tested
- [ ] User onboarding process validated

---

## 📝 Implementation Notes

This TODO represents a comprehensive enterprise-grade installation system. Each phase should be implemented incrementally with thorough testing before proceeding to the next phase.

**Priority Order:**
1. Phases 1-2: Core infrastructure and security (critical for any deployment)
2. Phase 3: Application deployment (core functionality)
3. Phase 4: User management (required for production use)
4. Phases 5-7: Operations, monitoring, and documentation (required for production operations)

**Estimated Implementation Time:**
- Development: 4-6 weeks
- Testing and validation: 2-3 weeks  
- Documentation: 1-2 weeks
- Total: 7-11 weeks for full production-ready system
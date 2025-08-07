# n8n Docker Setup 🚀

**Production-ready n8n deployment with zero-configuration setup and enterprise-grade security.**

[![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://docs.docker.com/compose/)
[![n8n](https://img.shields.io/badge/n8n-1.65.1-orange.svg)](https://n8n.io)
[![Security](https://img.shields.io/badge/Security-Auto--Generated-green.svg)](#security)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **One command. Zero configuration. Production ready.**

## ⚡ Quick Start

```bash
git clone https://github.com/rupesh43210/n8nDeploy.git
cd n8nDeploy
./n8n.sh start
```

**That's it!** Access your n8n instance at [http://localhost:5678](http://localhost:5678)

## ✨ What Makes This Special

- **🔧 Zero Configuration** - Runs out of the box with secure defaults
- **🛡️ Security First** - Auto-generated 32-character encryption keys
- **📦 Production Ready** - Optimized for real-world deployments  
- **🔄 One-Command Operations** - Deploy, backup, update, restore
- **💾 Smart Backups** - Automated daily backups with easy restore
- **📊 Health Monitoring** - Built-in status checks and logging

## 🚀 Features

### Automatic Setup
- **Environment Generation**: Creates `.env` with production-ready defaults
- **Secure Credentials**: Auto-generates encryption keys, passwords, JWT secrets
- **Docker Orchestration**: Handles container lifecycle and health checks
- **Permission Management**: Sets proper file permissions automatically

### Security & Compliance
- **Encrypted Data**: All sensitive data encrypted with auto-generated keys
- **Secure Defaults**: Basic auth disabled, built-in user management enabled
- **Git Protection**: Secrets never committed to version control
- **Audit Tools**: Built-in security validation and checks

### Production Features
- **Database Options**: SQLite (default) or PostgreSQL for scaling
- **Queue Support**: Redis integration for high-throughput workflows  
- **Backup System**: Automated backups with point-in-time restore
- **Update Management**: Safe updates with automatic rollback capability

## 📋 Available Commands

| Command | Description |
|---------|-------------|
| `./n8n.sh start` | Start n8n (auto-configures if needed) |
| `./n8n.sh stop` | Stop all services |
| `./n8n.sh restart` | Restart services |
| `./n8n.sh status` | Show service health and status |
| `./n8n.sh logs [service]` | View logs (all or specific service) |
| `./n8n.sh backup` | Create timestamped backup |
| `./n8n.sh restore <file>` | Restore from backup |
| `./n8n.sh update` | Update to latest version (with backup) |
| `./n8n.sh generate-secrets` | Generate new secure credentials |
| `./n8n.sh security-check` | Validate security configuration |
| `./n8n.sh help` | Show detailed help |

## 🗂️ Project Structure

```
n8n-docker-setup/
├── n8n.sh                 # 🎯 Main management script
├── docker-compose.yml     # 🐳 Container orchestration  
├── .env.template          # 📋 Configuration template
├── .env                   # 🔒 Your secrets (auto-generated)
├── data/                  # 💾 Persistent data
│   ├── n8n/              # n8n workflows and database
│   ├── redis/            # Redis data (if queue mode)
│   └── postgres/         # PostgreSQL data (if enabled)
├── backups/              # 🗄️ Backup files
├── logs/                 # 📊 Application logs  
└── wiki/                 # 📚 Comprehensive documentation
```

## 🔧 Configuration

### Default Setup (Zero Config)
- **Database**: SQLite (perfect for most use cases)
- **Port**: 5678 (configurable)
- **Auth**: Disabled (use n8n's built-in user management)
- **Timezone**: UTC (configurable)
- **Logging**: Info level

### Production Scaling
For high-traffic environments, easily switch to:
- **PostgreSQL** database
- **Redis** queue mode  
- **Multiple workers**
- **HTTPS** with reverse proxy

> 📖 **Detailed configuration guide:** [wiki/Configuration.md](wiki/Configuration.md)

## 🛡️ Security

### Auto-Generated Security
- **Encryption Keys**: 32-character base64 keys using cryptographically secure methods
- **Passwords**: 16-20 character random passwords with high entropy
- **JWT Secrets**: Secure session management tokens
- **File Permissions**: Automatic 600 permissions on sensitive files

### Security Best Practices
- Secrets never stored in git
- Environment isolation
- Regular security validation
- Audit trail in logs

### Security Validation
```bash
./n8n.sh security-check
```

## 💾 Backup & Recovery

### Automatic Backups
- **Schedule**: Daily at 2 AM (configurable)
- **Retention**: 30 days (configurable)  
- **Contents**: Workflows, database, configuration, custom nodes

### Manual Operations
```bash
# Create backup
./n8n.sh backup

# Restore from backup  
./n8n.sh restore n8n_backup_20240315_120000.tar.gz

# Safe updates with auto-backup
./n8n.sh update
```

## 🔄 Updates & Maintenance

### Safe Update Process
```bash
./n8n.sh update
```
1. Creates automatic backup
2. Pulls latest n8n version
3. Restarts with new version
4. Verifies successful update
5. Rollback available if issues occur

### Maintenance Tasks
- **Security Checks**: `./n8n.sh security-check`
- **Health Monitoring**: `./n8n.sh status`  
- **Log Analysis**: `./n8n.sh logs`
- **Credential Rotation**: `./n8n.sh generate-secrets`

## 🚦 System Requirements

### Minimum Requirements
- **Docker**: 20.10+ with Docker Compose
- **Memory**: 1GB RAM (2GB+ recommended)
- **Storage**: 2GB free disk space
- **OS**: Linux, macOS, or Windows with WSL2

### Recommended for Production
- **Memory**: 4GB+ RAM
- **Storage**: SSD with 10GB+ free space
- **CPU**: 2+ cores
- **Network**: Stable internet for updates

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Port 5678 in use | Change `N8N_PORT` in `.env` |
| Permission errors | `sudo chown -R $USER:$USER data/` |
| Container won't start | Check `./n8n.sh logs` for errors |
| Can't access web UI | Verify Docker is running: `docker info` |
| Need to reset everything | `./n8n.sh cleanup` (⚠️ deletes all data) |

## 📚 Documentation

### 📖 Comprehensive Wiki
- **[🏠 Wiki Home](wiki/Home.md)** - Documentation hub
- **[🚀 Quick Start](wiki/Quick-Start.md)** - 60-second deployment  
- **[⚙️ Configuration](wiki/Configuration.md)** - Environment settings
- **[📋 Command Reference](wiki/Command-Reference.md)** - All commands explained
- **[❓ FAQ](wiki/FAQ.md)** - Common questions answered
- **[🔒 Security Guide](wiki/Security.md)** - Hardening & best practices
- **[🏭 Production Deployment](wiki/Production-Deployment.md)** - Enterprise setup

### External Resources
- **[n8n Documentation](https://docs.n8n.io/)** - Official n8n docs
- **[Community Forum](https://community.n8n.io/)** - Get help from the community
- **[Docker Documentation](https://docs.docker.com/)** - Docker reference

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](wiki/Contributing.md) for details on:
- Code standards
- Testing requirements  
- Pull request process
- Security considerations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **[n8n Official Website](https://n8n.io)**
- **[Docker Hub - n8n](https://hub.docker.com/r/n8nio/n8n)**
- **[GitHub - n8n](https://github.com/n8n-io/n8n)**

---

<div align="center">

**⭐ If this project helped you, please give it a star!**

**🚀 Deploy n8n in seconds • 🛡️ Enterprise security • 📦 Production ready**

</div>
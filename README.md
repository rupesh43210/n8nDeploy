# n8n Docker Setup 🚀

**Production-ready n8n deployment with zero-configuration setup and enterprise-grade security.**

[![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://docs.docker.com/compose/)
[![n8n](https://img.shields.io/badge/n8n-1.65.1-orange.svg)](https://n8n.io)
[![Security](https://img.shields.io/badge/Security-Auto--Generated-green.svg)](#security)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **One command. Zero configuration. Production ready.**

## ⚡ Quick Start

### Linux/macOS
```bash
git clone https://github.com/rupesh43210/n8nDeploy.git
cd n8nDeploy
./n8n.sh start
```

### Windows
```cmd
git clone https://github.com/rupesh43210/n8nDeploy.git
cd n8nDeploy
n8n.bat start
```

### Universal (Cross-platform)
```bash
# Works on Windows, Linux, and macOS
python n8n-universal.py start
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
- **Database**: PostgreSQL with automatic setup and health checks
- **Caching & Queuing**: Redis for high-performance caching and queue management
- **Cross-Platform**: Universal Python script works on Windows, Linux, and macOS
- **Backup System**: Automated backups with point-in-time restore
- **Update Management**: Safe updates with automatic rollback capability

## 📋 Available Commands

### Linux/macOS Scripts
| Command | Description |
|---------|-------------|
| `./n8n.sh start` | Start n8n with PostgreSQL and Redis |
| `./n8n.sh stop` | Stop all services |
| `./n8n.sh restart` | Restart services |
| `./n8n.sh status` | Show service health and status |
| `./n8n.sh logs [service]` | View logs (n8n, postgres, redis, or all) |
| `./n8n.sh backup` | Create timestamped backup |
| `./n8n.sh restore <file>` | Restore from backup |
| `./n8n.sh update` | Update to latest version (with backup) |
| `./n8n.sh generate-secrets` | Generate new secure credentials |
| `./n8n.sh security-check` | Validate security configuration |
| `./n8n.sh help` | Show detailed help |

### Windows Scripts
| Command | Description |
|---------|-------------|
| `n8n.bat start` | Start n8n with PostgreSQL and Redis |
| `n8n.bat stop` | Stop all services |
| `n8n.bat restart` | Restart services |
| `n8n.bat status` | Show service health and status |
| `n8n.bat logs [service]` | View logs (n8n, postgres, redis, or all) |
| `n8n.bat backup` | Create timestamped backup |
| `n8n.bat help` | Show detailed help |

### Universal Python Script (All Platforms)
| Command | Description |
|---------|-------------|
| `python n8n-universal.py start` | Start n8n with PostgreSQL and Redis |
| `python n8n-universal.py stop` | Stop all services |
| `python n8n-universal.py restart` | Restart services |
| `python n8n-universal.py status` | Show service health and status |
| `python n8n-universal.py logs [service]` | View logs (n8n, postgres, redis, or all) |
| `python n8n-universal.py backup` | Create timestamped backup |
| `python n8n-universal.py help` | Show detailed help |

## 🗂️ Project Structure

```
n8n-docker-setup/
├── n8n.sh                 # 🎯 Linux/macOS management script
├── n8n.bat                # 🪟 Windows batch script
├── n8n-universal.py       # 🌐 Cross-platform Python script
├── docker-compose.yml     # 🐳 Container orchestration with PostgreSQL & Redis
├── .env.template          # 📋 Configuration template
├── .env                   # 🔒 Your secrets (auto-generated)
├── data/                  # 💾 Persistent data
│   ├── n8n/              # n8n workflows and settings
│   ├── redis/            # Redis data for caching and queues
│   └── postgres/         # PostgreSQL database
├── backups/              # 🗄️ Backup files
└── logs/                 # 📊 Application logs
# 📚 See GitHub Wiki for comprehensive documentation
```

## 🔧 Configuration

### Default Setup (Production-Ready)
- **Database**: PostgreSQL (production-ready with health checks)
- **Caching**: Redis for high-performance operations
- **Queue Mode**: Enabled for scalable workflow execution
- **Port**: 5678 (configurable)
- **Auth**: Disabled (use n8n's built-in user management)
- **Timezone**: UTC (configurable)
- **Logging**: Info level

### Advanced Configuration Options
For specific requirements, easily customize:
- Switch to **SQLite** for lighter deployments
- Configure **regular execution mode** instead of queue mode
- Set up **HTTPS** with reverse proxy
- Add **custom environment variables**
- Configure **backup retention** and scheduling

> 📖 **Detailed configuration guide:** [See Wiki - Configuration](../../wiki/Configuration)

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
- **Memory**: 2GB RAM (4GB+ recommended for PostgreSQL + Redis)
- **Storage**: 5GB free disk space (includes database)
- **OS**: Linux, macOS, or Windows (Windows 10+ for native Docker)
- **Python**: 3.7+ (for universal script)

### Recommended for Production
- **Memory**: 8GB+ RAM (PostgreSQL + Redis + queue workers)
- **Storage**: SSD with 20GB+ free space
- **CPU**: 4+ cores (for concurrent workflow execution)
- **Network**: Stable internet for updates

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Port 5678 in use | Change `N8N_PORT` in `.env` |
| PostgreSQL/Redis ports in use | Change `DB_POSTGRESDB_PORT`/`REDIS_PORT` in `.env` |
| Permission errors | `sudo chown -R $USER:$USER data/` |
| Container won't start | Check `./n8n.sh logs` or `python n8n-universal.py logs` |
| Database connection errors | Ensure PostgreSQL container is healthy |
| Redis connection errors | Check Redis container status and password |
| Can't access web UI | Verify Docker is running: `docker info` |
| Python script issues | Ensure Python 3.7+ installed |
| Need to reset everything | `./n8n.sh cleanup` (⚠️ deletes all data) |

## 📚 Documentation

### 📖 Comprehensive Wiki
**📚 [Visit the Complete Wiki](../../wiki) for detailed documentation:**

- **[🏠 Home](../../wiki/Home)** - Documentation hub and navigation
- **[🚀 Quick Start](../../wiki/Quick-Start)** - 60-second deployment guide  
- **[⚙️ Configuration](../../wiki/Configuration)** - Complete environment settings
- **[📋 Command Reference](../../wiki/Command-Reference)** - All commands with examples
- **[❓ FAQ](../../wiki/FAQ)** - Frequently asked questions
- **[🔒 Security Guide](../../wiki/Security)** - Security best practices
- **[🏭 Production Deployment](../../wiki/Production-Deployment)** - Enterprise setup guide

### External Resources
- **[n8n Documentation](https://docs.n8n.io/)** - Official n8n docs
- **[Community Forum](https://community.n8n.io/)** - Get help from the community
- **[Docker Documentation](https://docs.docker.com/)** - Docker reference

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](../../wiki/Contributing) for details on:
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
# n8n Docker Setup Wiki

Welcome to the comprehensive documentation for the **n8n Docker Setup** - a production-ready, zero-configuration deployment solution for n8n workflow automation.

## 🚀 Quick Links

### Getting Started
- [**Quick Start Guide**](Quick-Start.md) - Get up and running in 60 seconds
- [**Installation Requirements**](Installation.md) - Prerequisites and system requirements
- [**First-Time Setup**](First-Time-Setup.md) - Initial configuration and user account creation

### Configuration & Deployment
- [**Environment Configuration**](Configuration.md) - Understanding and customizing settings
- [**Production Deployment**](Production-Deployment.md) - Best practices for production environments
- [**Docker Compose Reference**](Docker-Compose.md) - Complete service configuration

### Management & Operations
- [**Command Reference**](Command-Reference.md) - All available n8n.sh commands
- [**Backup & Restore**](Backup-Restore.md) - Data protection and migration
- [**Updates & Maintenance**](Updates-Maintenance.md) - Keeping your deployment current

### Advanced Topics
- [**Security Guide**](Security.md) - Hardening and security best practices
- [**Performance Tuning**](Performance.md) - Optimization for high-traffic deployments
- [**Database Configuration**](Database.md) - SQLite vs PostgreSQL setup
- [**Scaling & High Availability**](Scaling.md) - Multi-instance and queue configuration

### Troubleshooting
- [**Common Issues**](Troubleshooting.md) - Solutions to frequent problems
- [**FAQ**](FAQ.md) - Frequently asked questions
- [**Logs & Debugging**](Debugging.md) - Diagnostic tools and techniques

### Development & Contribution
- [**Architecture Overview**](Architecture.md) - How the system works
- [**Contributing Guide**](Contributing.md) - How to contribute improvements
- [**Changelog**](Changelog.md) - Version history and updates

## 📊 Key Features

- **🔧 Zero Configuration** - One command deployment with secure defaults
- **🛡️ Security First** - Auto-generated encryption keys and secure permissions
- **📦 Production Ready** - Optimized for real-world deployments
- **💾 Backup System** - Automated backup and restore capabilities
- **🔄 Easy Updates** - Safe update process with rollback capability
- **📈 Scalable** - Supports single instance to multi-worker deployments

## 🆘 Need Help?

1. **Check the [FAQ](FAQ.md)** - Most questions are answered here
2. **Review [Troubleshooting](Troubleshooting.md)** - Common solutions
3. **Run diagnostics**: `./n8n.sh security-check` and `./n8n.sh status`
4. **Check logs**: `./n8n.sh logs` for detailed information

## 📈 Quick Stats

- **Setup Time**: < 60 seconds
- **Default Database**: SQLite (zero config)
- **Security**: Auto-generated 32-character encryption keys
- **Backup**: Automated daily backups (configurable)
- **Updates**: One-command updates with automatic backup

---

**💡 Tip**: Start with the [Quick Start Guide](Quick-Start.md) if you're new to this setup!
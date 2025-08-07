# N8N Docker Setup 🚀

A production-ready Docker setup for [n8n](https://n8n.io) workflow automation platform with built-in security, backup, and migration features.

## ✨ Features

- 🔧 **One-command deployment** with secure auto-generated credentials
- 🛡️ **Security-first approach** with encrypted secrets and proper permissions
- 📦 **Automatic backups** and easy restore functionality
- 🔄 **Safe updates** with rollback capability
- 🗄️ **Database flexibility** (SQLite for development, PostgreSQL for production)
- 📊 **Health monitoring** and comprehensive logging
- 🚦 **Environment templates** for development, staging, and production
- 📋 **Migration-ready** design for easy deployment portability

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- At least 2GB free disk space
- Port 5678 available (or configure different port)

### ⚡ Zero-Configuration Deployment

```bash
# Clone this repository
git clone <repository-url>
cd n8n-docker-setup

# One command to rule them all!
./n8n.sh start

# That's it! Access n8n at: http://localhost:5678
# No login required - create your admin account through n8n's setup wizard
```

**What happens automatically:**
- ✅ `.env` file created with production-ready defaults
- ✅ Secure credentials auto-generated (encryption keys, passwords)
- ✅ Docker containers started
- ✅ n8n running with optimal settings
- ✅ No manual configuration needed

**First-time setup:**
- Navigate to http://localhost:5678
- Create your admin account through n8n's built-in setup wizard
- No basic authentication required (recommended approach)

## 📋 Available Commands

The `n8n.sh` script provides all functionality you need:

### 🚀 **Deployment & Management**
```bash
./n8n.sh setup              # Initial setup with secure credentials
./n8n.sh start              # Start n8n services
./n8n.sh stop               # Stop n8n services
./n8n.sh restart            # Restart n8n services
./n8n.sh status             # Check service health and status
```

### 📊 **Monitoring & Logs**
```bash
./n8n.sh logs              # Show all service logs
./n8n.sh logs n8n          # Show n8n logs only
./n8n.sh logs redis        # Show Redis logs only
```

### 🔒 **Security & Credentials**
```bash
./n8n.sh generate-secrets   # Generate new secure credentials
./n8n.sh security-check     # Validate security configuration
```

### 💾 **Backup & Restore**
```bash
./n8n.sh backup             # Create timestamped backup
./n8n.sh restore backup.tar.gz  # Restore from backup file
```

### 🔄 **Updates & Maintenance**
```bash
./n8n.sh update             # Update n8n (with automatic backup)
./n8n.sh cleanup            # Remove all containers and data (DESTRUCTIVE)
```

### ❓ **Help**
```bash
./n8n.sh help               # Show detailed help and examples
```

## 🗂️ Project Structure

```
n8n-docker-setup/
├── n8n.sh                 # Main management script (handles everything!)
├── docker-compose.yml     # Docker Compose configuration
├── .env                   # Your environment config (auto-generated)
├── .env.template          # Production-ready template with secure placeholders
├── .gitignore             # Git ignore with security protections
├── README.md              # This documentation
├── data/                  # Persistent data (excluded from git)
│   ├── n8n/              # n8n workflows and data
│   ├── redis/            # Redis data (if using queue mode)
│   └── postgres/         # PostgreSQL data (if using postgres)
├── backups/              # Backup files (excluded from git)
└── logs/                 # Application logs (excluded from git)
```

## 🔧 Configuration

### Environment Variables

The setup uses environment files for configuration. Key variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `N8N_HOST` | Host for n8n | `0.0.0.0` |
| `N8N_PORT` | Port for n8n | `5678` |
| `N8N_BASIC_AUTH_PASSWORD` | Admin password | Auto-generated |
| `N8N_ENCRYPTION_KEY` | Data encryption key | Auto-generated |
| `DB_TYPE` | Database type | `sqlite` |
| `TZ` | Timezone | `Asia/Kolkata` |

### Configuration

The setup uses a single `.env` file that's automatically created with secure defaults:

- **`.env.example`** - Template showing all available options
- **`.env`** - Your actual configuration (auto-generated during setup)

### Custom Configuration

To customize your setup:

1. Edit the `.env` file directly with your settings (all scripts read from this file)
2. Or regenerate with new secrets: `./n8n.sh generate-secrets`
3. Restart services: `./n8n.sh restart`

**The setup is fully environment-driven** - all scripts and docker-compose read configurations from `.env`, with no hardcoded values.

## 🗄️ Database Options

### SQLite (Default)
- ✅ Perfect for development and small deployments
- ✅ Zero configuration required
- ✅ Automatic backups included
- ❌ Not suitable for high-traffic production

### PostgreSQL (Recommended for Production)
```bash
# 1. Edit .env and change database settings:
# DB_TYPE=postgresdb
# DB_POSTGRESDB_PASSWORD=your_secure_password

# 2. Uncomment postgres service in docker-compose.yml

# 3. Start services
./n8n.sh start
```

## 🔒 Security Features

### Automatic Security
- 🔐 **Auto-generated passwords** (16-32 characters)
- 🔑 **Encryption keys** using cryptographically secure methods
- 🛡️ **File permissions** protection (600 for .env files)
- 🚫 **Git protection** prevents accidental secret commits

### Security Best Practices
```bash
# Regular security validation
./n8n.sh security-check

# Generate new secrets (rotate every 90 days)
./n8n.sh generate-secrets

# Create regular backups
./n8n.sh backup
```

### Production Security Checklist
- [ ] Use PostgreSQL database
- [ ] Enable HTTPS with SSL certificates
- [ ] Set up firewall rules
- [ ] Use strong, unique passwords
- [ ] Enable regular backups
- [ ] Monitor access logs
- [ ] Keep n8n updated

## 💾 Backup & Restore

### Automatic Backups
Backups include:
- All n8n workflow data
- Database contents
- Configuration files
- Custom nodes (if any)

### Manual Backup
```bash
# Create backup
./n8n.sh backup
# Creates: backups/n8n_backup_YYYYMMDD_HHMMSS.tar.gz
```

### Restore Process
```bash
# List available backups
ls -la backups/

# Restore from specific backup
./n8n.sh restore n8n_backup_20240315_120000.tar.gz
```

## 🔄 Updates & Migration

### Safe Updates
```bash
# Update with automatic backup and rollback on failure
./n8n.sh update
```

The update process:
1. Creates automatic backup
2. Pulls latest n8n image
3. Restarts services
4. Verifies health
5. Shows success/failure status

### Migration Between Environments

1. **Create backup** on source system:
   ```bash
   ./n8n.sh backup
   ```

2. **Transfer files** to new system:
   ```bash
   # Copy the entire project directory
   scp -r n8n-docker-setup user@newserver:/path/to/destination
   ```

3. **Restore on target** system:
   ```bash
   cd /path/to/destination/n8n-docker-setup
   ./n8n.sh restore n8n_backup_YYYYMMDD_HHMMSS.tar.gz
   ```

## 🐛 Troubleshooting

### Common Issues

**Port already in use:**
```bash
# Change port in .env file
N8N_PORT=5679
./n8n.sh restart
```

**Permission errors:**
```bash
# Fix data directory permissions
sudo chown -R $USER:$USER data/
chmod 755 data/
```

**Database connection issues:**
```bash
# Check logs
./n8n.sh logs

# Reset database (CAUTION: destroys data)
./n8n.sh stop
rm -rf data/n8n/database.sqlite
./n8n.sh start
```

**Services won't start:**
```bash
# Check Docker status
docker info

# Check service status
./n8n.sh status

# View detailed logs
./n8n.sh logs
```

### Getting Help

1. **Check logs**: `./n8n.sh logs`
2. **Validate security**: `./n8n.sh security-check`
3. **Check service health**: `./n8n.sh status`
4. **View help**: `./n8n.sh help`

## 🔗 Access Information

After successful deployment:

- **Web Interface**: http://0.0.0.0:5678
- **Username**: admin
- **Password**: Shown during setup (also in logs)
- **API Endpoint**: http://0.0.0.0:5678/api
- **Webhook URL**: http://0.0.0.0:5678/webhook

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test thoroughly in development environment
4. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🔗 Resources

- [n8n Official Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

**⚡ Quick Start Reminder:**
```bash
./n8n.sh setup && ./n8n.sh start
```

**🔒 Security First:**
- Never commit `.env` files
- Regularly rotate secrets
- Use HTTPS in production
- Keep backups secure

**📞 Need Help?** Run `./n8n.sh help` for detailed command information.
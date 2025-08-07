# Frequently Asked Questions

Common questions and answers about the n8n Docker setup.

## 🚀 Getting Started

### Q: Do I need to configure anything before starting?
**A:** No! Just run `./n8n.sh start` and everything is configured automatically with secure defaults.

### Q: What happens on first run?
**A:** The script automatically:
- Creates a `.env` file with secure, random credentials
- Sets up Docker containers with optimal settings  
- Starts n8n with production-ready configuration
- No manual configuration required

### Q: Do I need to create user accounts?
**A:** No basic auth is required. Access http://localhost:5678 directly and create your admin account through n8n's built-in setup wizard.

---

## 🔐 Security & Authentication

### Q: Where are my passwords stored?
**A:** All credentials are auto-generated and stored in the `.env` file with 600 permissions. The file is protected by git and never committed to version control.

### Q: How do I find my auto-generated passwords?
**A:** Check your `.env` file:
```bash
grep PASSWORD .env
```
Or generate new ones: `./n8n.sh generate-secrets`

### Q: Should I enable basic authentication?
**A:** No, it's disabled by default (recommended). Use n8n's built-in user management instead, which is more secure and feature-rich.

### Q: How do I change my admin password?
**A:** Change it through n8n's web interface (User Settings). The basic auth password in `.env` is only used if you enable basic auth.

### Q: Are the auto-generated credentials secure?
**A:** Yes! They use:
- 32-character base64 encryption keys
- 16-20 character random passwords  
- Cryptographically secure generation methods
- Proper entropy from system random sources

---

## 🗄️ Database & Data

### Q: What database does it use by default?
**A:** SQLite - requires zero configuration and works great for most deployments. Your data is stored in `data/n8n/database.sqlite`.

### Q: When should I use PostgreSQL?
**A:** Consider PostgreSQL for:
- High-traffic production environments
- Multiple concurrent users
- Complex workflows with heavy database usage
- When you need advanced database features

### Q: How do I switch to PostgreSQL?
**A:** 
1. Edit `.env` and uncomment the PostgreSQL settings
2. Uncomment the postgres service in `docker-compose.yml`  
3. Run `./n8n.sh restart`

### Q: Where is my workflow data stored?
**A:** In the `data/n8n/` directory:
- `database.sqlite` - Main database
- Workflow files, credentials, and settings
- Custom nodes (if installed)

---

## 🔧 Configuration & Customization

### Q: How do I change the port?
**A:**
```bash
# Edit .env file
N8N_PORT=8080

# Restart
./n8n.sh restart
```

### Q: Can I use HTTPS?
**A:** Yes, but you'll need a reverse proxy (nginx, Caddy, etc.). The Docker setup handles HTTP, and your proxy handles SSL termination.

### Q: How do I add custom environment variables?
**A:** Edit the `.env` file directly and add your variables. They'll be automatically loaded on restart.

### Q: Can I modify the Docker Compose configuration?
**A:** Yes, edit `docker-compose.yml`, but be careful not to break the security and automation features.

---

## 💾 Backups & Updates

### Q: How often should I backup?
**A:** Backups are configured to run daily at 2 AM by default. You can also create manual backups with `./n8n.sh backup`.

### Q: What's included in backups?
**A:** Everything you need:
- All workflow data and configurations
- Database contents
- Environment configuration
- Custom nodes (if any)

### Q: How do I update n8n?
**A:** Run `./n8n.sh update`. It automatically:
- Creates a backup first
- Updates to the latest version
- Restarts services
- Verifies the update worked

### Q: What if an update breaks something?
**A:** Restore from the automatic backup created before the update:
```bash
./n8n.sh restore n8n_backup_[timestamp].tar.gz
```

---

## 🐳 Docker & System

### Q: What Docker images are used?
**A:** 
- `n8nio/n8n:1.65.1` - Main n8n application
- `redis:7-alpine` - For queue mode (optional)
- `postgres:15-alpine` - For PostgreSQL (optional)

### Q: How much disk space is needed?
**A:** Minimum 2GB free space recommended:
- Docker images: ~500MB
- n8n data: Grows with your workflows
- Backups: Depends on your data size

### Q: Can I run this on a server?
**A:** Yes! It's designed for production use. Make sure to:
- Use HTTPS with a reverse proxy
- Configure firewall rules
- Set up regular backups
- Monitor the services

### Q: What ports are used?
**A:**
- `5678` - n8n web interface (default, configurable)
- `6379` - Redis (only if using queue mode)
- `5432` - PostgreSQL (only if using PostgreSQL)

---

## 🔄 Troubleshooting

### Q: n8n won't start, what should I check?
**A:**
1. `./n8n.sh status` - Check service status
2. `./n8n.sh logs` - Look for error messages
3. `docker info` - Verify Docker is running
4. Check if port 5678 is available: `lsof -i :5678`

### Q: I get permission errors, how do I fix them?
**A:**
```bash
# Fix data directory permissions
sudo chown -R $USER:$USER data/
chmod 755 data/

# Restart services
./n8n.sh restart
```

### Q: The container keeps restarting, what's wrong?
**A:** Usually configuration issues:
1. Check logs: `./n8n.sh logs`
2. Look for environment variable errors
3. Verify `.env` file syntax (no spaces around `=`)
4. Check available disk space

### Q: How do I completely reset everything?
**A:**
```bash
# ⚠️ This deletes ALL data!
./n8n.sh cleanup

# Then start fresh
./n8n.sh start
```

---

## 🚦 Performance & Scaling

### Q: How many workflows can it handle?
**A:** Depends on complexity and resources, but the default setup can handle:
- SQLite: Hundreds of simple workflows
- PostgreSQL: Thousands of workflows
- Use queue mode for high-throughput scenarios

### Q: When should I use queue mode?
**A:** Consider queue mode for:
- High workflow execution volume
- Long-running workflows
- Multiple worker instances
- Better fault tolerance

### Q: How do I monitor performance?
**A:**
- `./n8n.sh status` - Service health
- `./n8n.sh logs` - Application logs
- Docker stats: `docker stats`
- System resources: `htop`, `df -h`

---

## 🔗 Integration & Development

### Q: Can I install custom nodes?
**A:** Yes! Custom nodes installed through n8n's interface are automatically persisted in the `data/n8n/nodes/` directory.

### Q: How do I use webhooks?
**A:** Webhooks work automatically. Your webhook URL will be:
```
http://your-domain.com:5678/webhook/your-webhook-name
```

### Q: Can I connect to external databases?
**A:** Yes, n8n supports many database connections. Configure them through n8n's credentials system.

### Q: How do I backup before making changes?
**A:**
```bash
# Always backup before major changes
./n8n.sh backup

# Make your changes...

# If something goes wrong, restore:
./n8n.sh restore backup_file.tar.gz
```

---

## 🆘 Still Need Help?

If your question isn't answered here:

1. **Check the logs**: `./n8n.sh logs`
2. **Run diagnostics**: `./n8n.sh security-check` and `./n8n.sh status`
3. **Review other wiki pages**:
   - [Troubleshooting Guide](Troubleshooting.md)
   - [Configuration Guide](Configuration.md)
   - [Command Reference](Command-Reference.md)
4. **Check n8n documentation**: https://docs.n8n.io/
5. **Community forum**: https://community.n8n.io/

---

**💡 Pro Tip**: Most issues are solved by checking logs (`./n8n.sh logs`) and ensuring proper file permissions!
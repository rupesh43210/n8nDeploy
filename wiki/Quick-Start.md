# Quick Start Guide

Get your n8n instance running in under 60 seconds with zero manual configuration.

## ⚡ One-Command Deployment

```bash
# 1. Clone the repository
git clone https://github.com/rupesh43210/n8nDeploy.git
cd n8nDeploy

# 2. Start n8n (that's it!)
./n8n.sh start

# 3. Access n8n
open http://localhost:5678
```

## 🎉 What Just Happened?

The `./n8n.sh start` command automatically:

- ✅ **Created `.env` file** with production-ready defaults
- ✅ **Generated secure credentials** (32-char encryption keys, strong passwords)
- ✅ **Started Docker containers** with optimal settings
- ✅ **Configured health checks** and monitoring
- ✅ **Set proper permissions** for security

## 🔐 First-Time Setup

1. **Open your browser** to http://localhost:5678
2. **No login required** - you'll see n8n's setup wizard
3. **Create your admin account** through n8n's interface
4. **Start building workflows** immediately

## 📋 Next Steps

Once n8n is running, explore these commands:

```bash
# Check status and health
./n8n.sh status

# View logs
./n8n.sh logs

# Create a backup
./n8n.sh backup

# Run security check
./n8n.sh security-check

# See all available commands
./n8n.sh help
```

## 🔧 Common Customizations

### Change Port
```bash
# Edit .env file
N8N_PORT=8080

# Restart services
./n8n.sh restart
```

### Enable Basic Auth (Optional)
```bash
# Edit .env file
N8N_BASIC_AUTH_ACTIVE=true

# Restart services  
./n8n.sh restart
```

### Use PostgreSQL Database
```bash
# Edit .env file - uncomment these lines:
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
# ... other postgres settings

# Uncomment postgres service in docker-compose.yml
# Restart services
./n8n.sh restart
```

## 🆘 Troubleshooting

### Port Already in Use
```bash
# Check what's using port 5678
lsof -i :5678

# Change port in .env
N8N_PORT=5679
./n8n.sh restart
```

### Container Won't Start
```bash
# Check logs for errors
./n8n.sh logs

# Check Docker daemon
docker info

# Restart with fresh data
./n8n.sh stop
rm -rf data/n8n/*
./n8n.sh start
```

### Permission Errors
```bash
# Fix data directory permissions
sudo chown -R $USER:$USER data/
chmod 755 data/
./n8n.sh restart
```

## 📚 Learn More

- [**Configuration Guide**](Configuration.md) - Detailed environment settings
- [**Security Best Practices**](Security.md) - Hardening your deployment
- [**Production Deployment**](Production-Deployment.md) - Real-world setup
- [**FAQ**](FAQ.md) - Common questions and answers

---

**🎯 Success!** Your n8n instance should now be running at http://localhost:5678
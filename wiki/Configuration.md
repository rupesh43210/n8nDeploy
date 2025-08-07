# Environment Configuration

Complete guide to customizing your n8n deployment through environment variables.

## 📁 Configuration Files

### `.env` (Auto-generated)
- **Purpose**: Your actual configuration with real secrets
- **Security**: Automatically set to 600 permissions, never committed to git
- **Creation**: Auto-generated on first `./n8n.sh start`

### `.env.template` (Template)
- **Purpose**: Template with placeholders for auto-generation
- **Security**: Safe to commit (contains no real secrets)
- **Usage**: Used by script to create `.env` files

## 🔧 Core Settings

### Host & Port Configuration
```bash
# Network settings
N8N_HOST=0.0.0.0          # Listen on all interfaces
N8N_PORT=5678             # Default port
N8N_PROTOCOL=http         # http or https
N8N_PATH=/                # URL path prefix
```

### Authentication Settings
```bash
# Basic Auth (disabled by default)
N8N_BASIC_AUTH_ACTIVE=false
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=auto-generated

# Note: Use n8n's built-in user management instead
```

## 🔐 Security Configuration

### Auto-Generated Secrets
```bash
# Encryption (32-character base64)
N8N_ENCRYPTION_KEY=auto-generated

# JWT Session Management (32-character base64)
N8N_JWT_SECRET=auto-generated

# Webhook Security (24-character)
N8N_WEBHOOK_TOKEN=auto-generated
```

### Security Headers
```bash
N8N_SECURE_COOKIE=false           # Set true for HTTPS
N8N_COOKIE_SAME_SITE=lax         # Cookie security
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
```

## 🗄️ Database Configuration

### SQLite (Default - Zero Config)
```bash
DB_TYPE=sqlite
DB_SQLITE_VACUUM_ON_STARTUP=true
```

### PostgreSQL (Production)
```bash
# Uncomment these in .env:
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=auto-generated
DB_POSTGRESDB_POOL_SIZE=10
```

## 🚀 Performance Settings

### Memory & Execution
```bash
# Node.js memory limit (MB)
NODE_OPTIONS=--max-old-space-size=2048

# Execution timeout (seconds)
N8N_MAX_EXECUTION_TIMEOUT=3600

# Payload size limit (MB)
N8N_PAYLOAD_SIZE_MAX=16
```

### Execution Modes
```bash
# Single instance
EXECUTIONS_MODE=regular

# Production scaling (requires Redis)
EXECUTIONS_MODE=queue
QUEUE_MODE=redis
```

## 📡 Redis Configuration (Scaling)

For production scaling with multiple workers:

```bash
# Uncomment in .env:
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=auto-generated
REDIS_DB=0

# Uncomment redis service in docker-compose.yml
```

## 📊 Logging & Monitoring

### Log Settings
```bash
N8N_LOG_LEVEL=info           # error, warn, info, verbose, debug
N8N_LOG_OUTPUT=console       # console, file
```

### Diagnostics
```bash
N8N_DIAGNOSTICS_ENABLED=false
N8N_VERSION_NOTIFICATIONS_ENABLED=true
```

## 🌍 Localization

### Timezone & Locale
```bash
TZ=UTC                       # System timezone
GENERIC_TIMEZONE=UTC         # n8n timezone
N8N_DEFAULT_LOCALE=en        # Default language
```

## 📧 Email Configuration (Optional)

### SMTP Settings
```bash
# Uncomment and configure:
# N8N_SMTP_HOST=smtp.gmail.com
# N8N_SMTP_PORT=587
# N8N_SMTP_USER=your-email@gmail.com
# N8N_SMTP_PASS=your-app-password
# N8N_SMTP_SENDER=your-email@gmail.com
```

## 💾 Backup Configuration

### Backup Settings
```bash
BACKUP_PATH=./backups
BACKUP_SCHEDULE="0 2 * * *"    # Daily at 2 AM
BACKUP_RETENTION_DAYS=30
```

## 🏥 Health Check Configuration

### Docker Health Checks
```bash
HEALTHCHECK_INTERVAL=30s
HEALTHCHECK_TIMEOUT=10s
HEALTHCHECK_RETRIES=3
```

## 🔄 Configuration Management

### Regenerate Secrets
```bash
# Generate new credentials
./n8n.sh generate-secrets

# This creates new passwords and keys while preserving your settings
```

### Manual Configuration
```bash
# Edit .env file directly
nano .env

# Apply changes
./n8n.sh restart
```

### Configuration Validation
```bash
# Check current configuration
./n8n.sh security-check

# Validate environment
./n8n.sh status
```

## 📋 Environment Examples

### Development
```bash
N8N_HOST=localhost
N8N_PORT=5678
N8N_LOG_LEVEL=debug
DB_TYPE=sqlite
N8N_BASIC_AUTH_ACTIVE=false
```

### Production
```bash
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_SECURE_COOKIE=true
N8N_LOG_LEVEL=info
DB_TYPE=postgresdb
EXECUTIONS_MODE=queue
```

## ⚠️ Important Notes

1. **Never commit `.env` files** - they contain real secrets
2. **Regenerate secrets regularly** - use `./n8n.sh generate-secrets`
3. **Use HTTPS in production** - configure reverse proxy
4. **Backup regularly** - automated backups are configured by default
5. **Monitor logs** - use `./n8n.sh logs` for troubleshooting

## 🔗 Related Guides

- [**Production Deployment**](Production-Deployment.md) - Production-specific settings
- [**Security Guide**](Security.md) - Security hardening
- [**Database Configuration**](Database.md) - Database setup details
- [**Performance Tuning**](Performance.md) - Optimization guide
# Production Deployment Guide

Complete guide for deploying n8n in production environments with enterprise-grade security and performance.

## 🏭 Production Checklist

### ✅ Pre-Deployment
- [ ] Server meets [minimum requirements](#system-requirements)
- [ ] Domain name configured with DNS
- [ ] SSL certificate obtained
- [ ] Firewall rules configured
- [ ] Backup storage location prepared
- [ ] Monitoring tools ready

### ✅ Deployment
- [ ] Clone repository and configure environment
- [ ] Switch to PostgreSQL database
- [ ] Configure reverse proxy with SSL
- [ ] Set up automated backups
- [ ] Configure monitoring and alerting
- [ ] Test all functionality

### ✅ Post-Deployment
- [ ] Security hardening completed
- [ ] Performance baseline established
- [ ] Disaster recovery plan documented
- [ ] Team training completed

---

## 🖥️ System Requirements

### Minimum Production Server
```
CPU:     2 cores
RAM:     4GB (8GB recommended)
Storage: 20GB SSD (50GB+ recommended)
Network: 1Gbps connection
OS:      Ubuntu 22.04 LTS / CentOS 8 / Amazon Linux 2
```

### High-Availability Setup
```
CPU:     4+ cores per node
RAM:     8GB+ per node
Storage: 100GB+ SSD with RAID
Network: Multiple network interfaces
Load:    Load balancer (nginx/HAProxy)
DB:      Managed PostgreSQL (RDS/CloudSQL)
```

---

## 🔧 Production Configuration

### 1. Environment Setup

Create production-optimized `.env`:

```bash
# Production hosting
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_SECURE_COOKIE=true

# Performance settings
NODE_OPTIONS=--max-old-space-size=4096
N8N_MAX_EXECUTION_TIMEOUT=7200
N8N_PAYLOAD_SIZE_MAX=32

# Database (PostgreSQL required)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=your-postgres-host
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n_production
DB_POSTGRESDB_USER=n8n_user
DB_POSTGRESDB_PASSWORD=secure_password_here
DB_POSTGRESDB_POOL_SIZE=20

# Queue mode for scaling
EXECUTIONS_MODE=queue
QUEUE_MODE=redis
REDIS_HOST=your-redis-host
REDIS_PORT=6379
REDIS_PASSWORD=redis_password_here

# Security
N8N_COOKIE_SAME_SITE=strict
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Monitoring
N8N_LOG_LEVEL=info
N8N_DIAGNOSTICS_ENABLED=false
```

### 2. Docker Compose Production Override

Create `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  n8n:
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
        reservations:
          memory: 2G
          cpus: '1.0'
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    healthcheck:
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 120s

  # External PostgreSQL - remove if using managed database
  postgres:
    image: postgres:15-alpine
    container_name: n8n-postgres-prod
    restart: unless-stopped
    environment:
      POSTGRES_DB: n8n_production
      POSTGRES_USER: n8n_user
      POSTGRES_PASSWORD: ${DB_POSTGRESDB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'

  # Redis for queue mode
  redis:
    image: redis:7-alpine
    container_name: n8n-redis-prod
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'

volumes:
  postgres_data:
  redis_data:
```

---

## 🌐 Reverse Proxy Setup

### Option 1: Nginx with Let's Encrypt

**Install Certbot:**
```bash
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx
```

**Nginx Configuration** (`/etc/nginx/sites-available/n8n`):
```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=n8n:10m rate=10r/m;
    
    location / {
        limit_req zone=n8n burst=5;
        
        proxy_pass http://127.0.0.1:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

**Enable and get certificate:**
```bash
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
sudo certbot --nginx -d your-domain.com
```

### Option 2: Caddy (Automatic HTTPS)

**Caddyfile:**
```
your-domain.com {
    reverse_proxy localhost:5678
    
    header {
        X-Frame-Options DENY
        X-Content-Type-Options nosniff
        X-XSS-Protection "1; mode=block"
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
    }
}
```

---

## 🔐 Security Hardening

### 1. Server Security

**Update system:**
```bash
sudo apt update && sudo apt upgrade -y
```

**Configure firewall:**
```bash
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny 5678/tcp  # Only allow through reverse proxy
sudo ufw enable
```

**Disable root login:**
```bash
# Edit /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
sudo systemctl restart ssh
```

### 2. Application Security

**Generate strong credentials:**
```bash
./n8n.sh generate-secrets
```

**Set strict file permissions:**
```bash
chmod 600 .env
chmod 700 data/
chmod 755 n8n.sh
```

**Regular security audits:**
```bash
# Add to crontab for weekly checks
0 2 * * 0 /path/to/n8n.sh security-check >> /var/log/n8n-security.log 2>&1
```

### 3. Network Security

**Use private networks:**
- Database and Redis on private network only
- n8n container not directly exposed to internet
- All traffic through reverse proxy

---

## 📊 Monitoring & Logging

### 1. Application Monitoring

**Health check script** (`health-check.sh`):
```bash
#!/bin/bash
URL="https://your-domain.com/healthz"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ $STATUS -eq 200 ]; then
    echo "n8n is healthy"
    exit 0
else
    echo "n8n health check failed: HTTP $STATUS"
    exit 1
fi
```

**Add to crontab:**
```bash
*/5 * * * * /path/to/health-check.sh
```

### 2. Log Management

**Centralized logging with rsyslog:**
```bash
# /etc/rsyslog.d/n8n.conf
$ModLoad imfile
$InputFileName /path/to/n8n/logs/n8n.log
$InputFileTag n8n:
$InputFileStateFile stat-n8n
$InputFileSeverity info
$InputFileFacility local0
$InputRunFileMonitor

local0.* @log-server:514
```

### 3. Performance Monitoring

**Resource monitoring script:**
```bash
#!/bin/bash
docker stats --no-stream --format "table {{.Container}}\\t{{.CPUPerc}}\\t{{.MemUsage}}" n8n
```

---

## 💾 Production Backup Strategy

### 1. Automated Backups

**Daily backup script** (`production-backup.sh`):
```bash
#!/bin/bash
set -e

BACKUP_DIR="/mnt/backup/n8n"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="n8n_prod_backup_$DATE.tar.gz"

# Create backup
/path/to/n8n.sh backup

# Move to backup storage
mv /path/to/backups/n8n_backup_*.tar.gz "$BACKUP_DIR/$BACKUP_FILE"

# Upload to cloud storage (optional)
aws s3 cp "$BACKUP_DIR/$BACKUP_FILE" s3://your-backup-bucket/n8n/

# Cleanup old backups (keep 30 days)
find "$BACKUP_DIR" -name "n8n_prod_backup_*.tar.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_FILE"
```

**Add to crontab:**
```bash
0 2 * * * /path/to/production-backup.sh >> /var/log/n8n-backup.log 2>&1
```

### 2. Database Backups

**PostgreSQL backup:**
```bash
#!/bin/bash
PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > backup_$(date +%Y%m%d).sql
```

---

## 🚀 Deployment Steps

### 1. Server Preparation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Application Deployment

```bash
# Clone repository
git clone https://github.com/rupesh43210/n8nDeploy.git
cd n8nDeploy

# Configure for production
cp .env.template .env
# Edit .env with production values

# Start services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Verify deployment
./n8n.sh status
./n8n.sh security-check
```

### 3. SSL and Proxy Setup

```bash
# Install and configure nginx
sudo apt install nginx
# Configure as shown above

# Get SSL certificate
sudo certbot --nginx -d your-domain.com
```

---

## 📈 Performance Optimization

### 1. Resource Allocation

**Adjust Docker resources based on usage:**
```yaml
# In docker-compose.prod.yml
deploy:
  resources:
    limits:
      memory: 8G      # Increase for heavy workloads
      cpus: '4.0'     # Scale based on CPU usage
```

### 2. Database Optimization

**PostgreSQL tuning (`postgresql.conf`):**
```
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
max_connections = 100
```

### 3. Queue Mode Setup

For high-throughput workflows:

```bash
# In .env
EXECUTIONS_MODE=queue
QUEUE_MODE=redis

# Scale workers
docker-compose up --scale n8n=3
```

---

## 🔄 Disaster Recovery

### 1. Recovery Procedures

**Complete system restore:**
```bash
# 1. Fresh server setup
# 2. Install Docker and dependencies
# 3. Clone repository
git clone https://github.com/rupesh43210/n8nDeploy.git
cd n8nDeploy

# 4. Restore from backup
./n8n.sh restore /path/to/backup.tar.gz

# 5. Start services
./n8n.sh start
```

### 2. High Availability

**Multi-node setup:**
- Load balancer (nginx/HAProxy)
- Multiple n8n instances
- Shared database (managed PostgreSQL)
- Shared Redis cluster
- Synchronized backups

---

## ⚡ Quick Production Commands

```bash
# Start production environment
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Monitor resources
docker stats

# Check logs
./n8n.sh logs

# Performance test
curl -w "@curl-format.txt" -o /dev/null -s "https://your-domain.com/healthz"

# Security audit
./n8n.sh security-check

# Create production backup
./n8n.sh backup
```

---

## 📋 Production Maintenance Schedule

### Daily
- [ ] Health check monitoring
- [ ] Log review
- [ ] Automated backups

### Weekly  
- [ ] Security audit
- [ ] Performance review
- [ ] Backup verification

### Monthly
- [ ] Credential rotation
- [ ] System updates
- [ ] Disaster recovery test

### Quarterly
- [ ] Security review
- [ ] Architecture review
- [ ] Capacity planning

---

**🎯 Result**: A production-ready n8n deployment with enterprise-grade security, monitoring, and reliability.
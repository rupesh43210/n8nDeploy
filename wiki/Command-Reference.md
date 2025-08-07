# Command Reference

Complete reference for all `n8n.sh` commands with examples and use cases.

## 🚀 Deployment Commands

### `./n8n.sh setup`
Initial setup with secure credentials generation.

```bash
./n8n.sh setup
```

**What it does:**
- Creates `.env` file from template
- Generates secure encryption keys and passwords
- Creates required directories with proper permissions
- Sets up production-ready defaults

**When to use:**
- First-time setup (optional - `start` does this automatically)
- After cleaning up configuration files

---

### `./n8n.sh start`
Start n8n services with auto-configuration.

```bash
./n8n.sh start
```

**What it does:**
- Auto-creates `.env` if missing (calls `setup` internally)
- Checks Docker dependencies
- Starts Docker Compose services
- Performs health checks
- Shows access information

**Output example:**
```
=== Starting N8N Services ===
✓ Services started successfully  
✓ n8n is running and healthy!
✓ Access your n8n instance at: http://0.0.0.0:5678
```

---

### `./n8n.sh stop`
Stop all n8n services gracefully.

```bash
./n8n.sh stop
```

**What it does:**
- Stops all Docker containers
- Removes containers (data is preserved)
- Removes Docker networks

---

### `./n8n.sh restart`
Restart services (stop + start).

```bash
./n8n.sh restart
```

**When to use:**
- After configuration changes
- To apply updates
- When troubleshooting issues

---

## 📊 Monitoring Commands

### `./n8n.sh status`
Show comprehensive status information.

```bash
./n8n.sh status
```

**Output includes:**
- Container status and health
- Service uptime
- Health check results
- Port bindings

**Example output:**
```
=== Service Status ===
NAME    IMAGE            STATUS           PORTS
n8n     n8nio/n8n:latest Up 2 hours      0.0.0.0:5678->5678/tcp

✓ n8n is responding and healthy
```

---

### `./n8n.sh logs [service]`
View service logs in real-time.

```bash
# All services
./n8n.sh logs

# Specific service
./n8n.sh logs n8n
./n8n.sh logs redis
```

**Options:**
- No argument: Shows all service logs
- `n8n`: Shows only n8n logs  
- `redis`: Shows only Redis logs (if enabled)

**Tips:**
- Use `Ctrl+C` to exit log viewing
- Logs are also saved to `logs/` directory

---

## 💾 Backup & Restore Commands

### `./n8n.sh backup`
Create timestamped backup of all data and configuration.

```bash
./n8n.sh backup
```

**What gets backed up:**
- All n8n workflow data
- Database contents (SQLite file or database dump)
- Configuration files (`.env`)
- Custom nodes (if any)

**Output:**
```
=== Creating Backup ===
✓ Backup created: n8n_backup_20240315_120000.tar.gz
ℹ Backup location: /path/to/backups/n8n_backup_20240315_120000.tar.gz
```

---

### `./n8n.sh restore <backup-file>`
Restore from a backup file.

```bash
# Restore from specific backup
./n8n.sh restore n8n_backup_20240315_120000.tar.gz

# Restore from full path
./n8n.sh restore /path/to/backup.tar.gz
```

**⚠️ Warning:** This will overwrite current data!

**Process:**
1. Confirms with user (y/N prompt)
2. Stops services
3. Extracts backup
4. Starts services
5. Verifies restoration

---

## 🔄 Update & Maintenance Commands

### `./n8n.sh update`
Update n8n to latest version with automatic backup.

```bash
./n8n.sh update
```

**Safe update process:**
1. Creates automatic backup
2. Pulls latest Docker images
3. Restarts services with new version
4. Verifies successful update

**Rollback:** If update fails, restore from the automatic backup created.

---

### `./n8n.sh generate-secrets`
Generate new secure credentials.

```bash
./n8n.sh generate-secrets
```

**What it regenerates:**
- Admin password (16 characters)
- Encryption key (32 characters base64)
- JWT secret (32 characters base64)
- Webhook token (24 characters)

**Process:**
1. Backs up current `.env`
2. Generates new secure credentials
3. Updates `.env` file
4. Shows new admin password
5. Requires restart to apply

---

## 🔒 Security Commands

### `./n8n.sh security-check`
Run comprehensive security validation.

```bash
./n8n.sh security-check
```

**Checks performed:**
- `.env` file permissions (should be 600)
- Weak or default passwords
- Encryption key strength
- Configuration security

**Example output:**
```
=== Security Check ===
✓ .env file permissions: 600 (secure)
✓ Security check passed!
```

**If issues found:**
```
⚠ .env file permissions: 644 (recommended: 600)
⚠ Found 1 security issues. Consider running: ./n8n.sh generate-secrets
```

---

## 🧹 Maintenance Commands

### `./n8n.sh cleanup`
⚠️ **DESTRUCTIVE** - Remove all containers, images, and data.

```bash
./n8n.sh cleanup
```

**⚠️ WARNING:** This command will:
- Stop all containers
- Remove all Docker images
- Delete all data directories
- **ALL DATA WILL BE LOST**

**Confirmation required:** User must type 'y' to confirm.

**When to use:**
- Complete reset/reinstall
- Cleaning up after testing
- Freeing disk space (with caution)

---

## ❓ Help Commands

### `./n8n.sh help`
Show comprehensive help information.

```bash
./n8n.sh help
```

**Shows:**
- All available commands
- Usage examples
- Access information
- Security notes

---

## 📋 Command Chaining Examples

### Complete Setup Flow
```bash
# From scratch to running
git clone <repo>
cd n8n-docker-setup
./n8n.sh start
```

### Maintenance Workflow  
```bash
# Regular maintenance
./n8n.sh backup
./n8n.sh security-check
./n8n.sh update
./n8n.sh status
```

### Troubleshooting Workflow
```bash
# When things go wrong
./n8n.sh status
./n8n.sh logs
./n8n.sh restart
./n8n.sh security-check
```

### Migration Workflow
```bash
# On source system
./n8n.sh backup

# Transfer backup file to new system

# On target system
./n8n.sh restore backup_file.tar.gz
```

## ⚡ Quick Reference Table

| Command | Purpose | Safe | Requires Restart |
|---------|---------|------|------------------|
| `setup` | Initial configuration | ✅ | No |
| `start` | Start services | ✅ | No |
| `stop` | Stop services | ✅ | No |
| `restart` | Restart services | ✅ | No |
| `status` | Check health | ✅ | No |
| `logs` | View logs | ✅ | No |
| `backup` | Create backup | ✅ | No |
| `restore` | Restore backup | ⚠️ | No |
| `update` | Update n8n | ⚠️ | No |
| `generate-secrets` | New credentials | ✅ | Yes |
| `security-check` | Security audit | ✅ | No |
| `cleanup` | ⚠️ Delete everything | ❌ | No |
| `help` | Show help | ✅ | No |

## 💡 Pro Tips

1. **Always backup before updates:** `./n8n.sh backup && ./n8n.sh update`
2. **Check logs for errors:** `./n8n.sh logs` when troubleshooting
3. **Regular security checks:** `./n8n.sh security-check` monthly
4. **Monitor service health:** `./n8n.sh status` in monitoring scripts
5. **Use tab completion:** The script supports command tab completion
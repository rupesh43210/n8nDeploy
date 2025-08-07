#!/bin/bash

# N8N Docker Management Script
# One script to rule them all - deploy, manage, update, and maintain n8n

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
LOG_FILE="$SCRIPT_DIR/logs/n8n-$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="$SCRIPT_DIR/backups"

# Ensure logs directory exists
mkdir -p "$SCRIPT_DIR/logs"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "${PURPLE}$1${NC}" | tee -a "$LOG_FILE"
}

print_cmd() {
    echo -e "${CYAN}$ $1${NC}"
}

# Function to show banner
show_banner() {
    cat << 'EOF'
 ███▄    █  █    ██  ███▄    █ 
 ██ ▀█   █  ██  ▓██▒ ██ ▀█   █ 
▓██  ▀█ ██▒▓██  ▒██░▓██  ▀█ ██▒
▓██▒  ▐▌██▒▓▓█  ░██░▓██▒  ▐▌██▒
▒██░   ▓██░▒▒█████▓ ▒██░   ▓██░
░ ▒░   ▒ ▒ ░▒▓▒ ▒ ▒ ░ ▒░   ▒ ▒ 
░ ░░   ░ ▒░░░▒░ ░ ░ ░ ░░   ░ ▒░
   ░   ░ ░  ░░░ ░ ░    ░   ░ ░ 
         ░    ░              ░ 
        Docker Management
EOF
}

# Function to load environment variables
load_env() {
    if [ -f "$ENV_FILE" ]; then
        # Source .env file to load variables
        set -a  # Automatically export all variables
        source "$ENV_FILE"
        set +a  # Stop auto-export
    fi
}

# Function to check dependencies
check_dependencies() {
    local missing=()
    
    if ! command -v docker &> /dev/null; then
        missing+=("Docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing+=("Docker Compose")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing[*]}"
        print_status "Please install the missing dependencies and try again"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
}

# Function to generate secure password
generate_password() {
    local length=${1:-20}
    if command -v openssl &> /dev/null; then
        openssl rand -base64 32 | tr -d "=+/" | cut -c1-${length}
    elif command -v python3 &> /dev/null; then
        python3 -c "import secrets, string; print(''.join(secrets.choice(string.ascii_letters + string.digits + '!@#$%^&*') for i in range($length)))"
    else
        date +%s | sha256sum | base64 | head -c ${length}
    fi
}

# Function to generate encryption key
generate_encryption_key() {
    local length=${1:-32}
    if command -v openssl &> /dev/null; then
        openssl rand -base64 ${length}
    elif command -v python3 &> /dev/null; then
        python3 -c "import secrets; print(secrets.token_urlsafe($length))"
    else
        date +%s | sha256sum | base64 | head -c ${length}
    fi
}

# Function to safely replace value in .env file
safe_env_replace() {
    local key="$1"
    local value="$2"
    local file="$3"
    
    # Create a temporary file with the replacement
    local temp_file=$(mktemp)
    
    # Use awk for safe replacement that handles special characters
    awk -F'=' -v key="$key" -v value="$value" '
        $1 == key { print key "=" value; next }
        { print }
    ' "$file" > "$temp_file"
    
    # Move temp file to original
    mv "$temp_file" "$file"
}

# Function to ensure .env file exists with secure defaults
ensure_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        print_status "Creating environment file with production-ready defaults..."
        create_env_file
    fi
}

# Function to create .env file from template
create_env_file() {
    # Generate secure credentials
    ADMIN_PASSWORD=$(generate_password 16)
    ENCRYPTION_KEY=$(generate_encryption_key 32)
    JWT_SECRET=$(generate_encryption_key 32)
    WEBHOOK_TOKEN=$(generate_encryption_key 24)
    DB_PASSWORD=$(generate_password 20)
    REDIS_PASSWORD=$(generate_password 16)
    
    # Use .env.template for configuration
    local template_file=".env.template"
    if [ ! -f "$template_file" ]; then
        print_error "Template file $template_file not found!"
        print_status "Please ensure .env.template exists in the project directory"
        exit 1
    fi
    
    # Create .env file from template with timestamp
    {
        echo "# Generated on $(date) by n8n.sh"
        echo "# Production-ready configuration with secure auto-generated credentials"
        echo ""
        cat "$template_file"
    } > "$ENV_FILE"
    
    # Replace placeholders with generated values using sed
    sed -i.tmp "s/__ADMIN_PASSWORD__/$ADMIN_PASSWORD/g" "$ENV_FILE"
    sed -i.tmp "s|__ENCRYPTION_KEY__|$ENCRYPTION_KEY|g" "$ENV_FILE"
    sed -i.tmp "s|__JWT_SECRET__|$JWT_SECRET|g" "$ENV_FILE"
    sed -i.tmp "s|__WEBHOOK_TOKEN__|$WEBHOOK_TOKEN|g" "$ENV_FILE"
    sed -i.tmp "s/__DB_PASSWORD__/$DB_PASSWORD/g" "$ENV_FILE"
    sed -i.tmp "s/__REDIS_PASSWORD__/$REDIS_PASSWORD/g" "$ENV_FILE"
    
    # Remove backup files
    rm -f "$ENV_FILE.tmp"
    
    # Set secure permissions
    chmod 600 "$ENV_FILE"
    
    print_success "Environment file created with secure auto-generated credentials"
    print_status "Basic authentication is DISABLED by default for first-time setup"
    print_status "Configure user accounts through n8n's web interface at http://localhost:5678"
    print_warning "Credentials are available in .env file if needed for advanced configuration"
}

# Function to setup environment (enhanced)
setup_environment() {
    print_header "=== Setting Up Environment ==="
    
    # Create data directories with proper permissions
    mkdir -p data/{n8n,redis,postgres} backups logs
    chmod 755 data backups logs
    
    # Ensure .env file exists
    if [ ! -f "$ENV_FILE" ]; then
        create_env_file
    else
        print_status "Environment file already exists"
        print_status "Run 'generate-secrets' command to regenerate credentials if needed"
    fi
    
    print_success "Environment setup completed"
    print_success "Ready to start n8n with: ./n8n.sh start"
}

# Function to start services
start_services() {
    print_header "=== Starting N8N Services ==="
    
    check_dependencies
    
    # Auto-create .env file if it doesn't exist
    ensure_env_file
    
    # Load environment variables
    load_env
    
    print_status "Starting services with docker-compose..."
    
    if docker-compose --env-file="$ENV_FILE" up -d; then
        print_success "Services started successfully"
        
        # Wait a moment for health check
        sleep 10
        print_status "Checking service health..."
        
        local n8n_url="http://${N8N_HOST:-localhost}:${N8N_PORT:-5678}"
        if curl -s -f "${n8n_url}/healthz" > /dev/null 2>&1; then
            print_success "n8n is running and healthy!"
            print_success "Access your n8n instance at: ${n8n_url}"
            if [ -n "$N8N_BASIC_AUTH_PASSWORD" ]; then
                print_status "Username: ${N8N_BASIC_AUTH_USER:-admin}"
                print_status "Password: $N8N_BASIC_AUTH_PASSWORD"
            fi
        else
            print_warning "n8n may still be starting up. Check logs if needed."
        fi
    else
        print_error "Failed to start services"
        exit 1
    fi
}

# Function to stop services
stop_services() {
    print_header "=== Stopping N8N Services ==="
    
    if docker-compose --env-file="$ENV_FILE" down; then
        print_success "Services stopped successfully"
    else
        print_error "Failed to stop services"
        exit 1
    fi
}

# Function to restart services
restart_services() {
    print_header "=== Restarting N8N Services ==="
    stop_services
    start_services
}

# Function to show logs
show_logs() {
    print_header "=== N8N Service Logs ==="
    
    case "${1:-all}" in
        "n8n")
            docker-compose --env-file="$ENV_FILE" logs -f n8n
            ;;
        "redis")
            docker-compose --env-file="$ENV_FILE" logs -f redis
            ;;
        "all"|*)
            docker-compose --env-file="$ENV_FILE" logs -f
            ;;
    esac
}

# Function to check status
check_status() {
    print_header "=== Service Status ==="
    
    # Load environment variables
    load_env
    
    docker-compose --env-file="$ENV_FILE" ps
    
    echo
    print_status "Health Check:"
    
    local n8n_url="http://${N8N_HOST:-localhost}:${N8N_PORT:-5678}"
    if curl -s -f "${n8n_url}/healthz" > /dev/null 2>&1; then
        print_success "n8n is responding and healthy"
    else
        print_warning "n8n is not responding or still starting"
    fi
}

# Function to create backup
create_backup() {
    print_header "=== Creating Backup ==="
    
    mkdir -p "$BACKUP_DIR"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/n8n_backup_$timestamp.tar.gz"
    
    print_status "Creating backup archive..."
    
    if tar -czf "$backup_file" -C "$SCRIPT_DIR" data/ .env 2>/dev/null; then
        print_success "Backup created: $(basename "$backup_file")"
        print_status "Backup location: $backup_file"
    else
        print_error "Failed to create backup"
        exit 1
    fi
}

# Function to restore from backup
restore_backup() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        print_error "Please specify a backup file to restore"
        print_status "Available backups:"
        ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null || print_status "No backups found"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ] && [ -f "$BACKUP_DIR/$backup_file" ]; then
        backup_file="$BACKUP_DIR/$backup_file"
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    print_header "=== Restoring Backup ==="
    print_warning "This will overwrite current data and configuration!"
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restore cancelled"
        exit 0
    fi
    
    print_status "Stopping services..."
    stop_services
    
    print_status "Extracting backup..."
    if tar -xzf "$backup_file" -C "$SCRIPT_DIR"; then
        print_success "Backup restored successfully"
        print_status "Starting services..."
        start_services
    else
        print_error "Failed to restore backup"
        exit 1
    fi
}

# Function to update n8n
update_n8n() {
    print_header "=== Updating N8N ==="
    
    # Create backup first
    print_status "Creating backup before update..."
    create_backup
    
    print_status "Pulling latest n8n image..."
    docker-compose --env-file="$ENV_FILE" pull
    
    print_status "Restarting services with new image..."
    restart_services
    
    print_success "Update completed successfully!"
}

# Function to generate new secrets
generate_secrets() {
    print_header "=== Generating New Secrets ==="
    
    if [ ! -f "$ENV_FILE" ]; then
        print_error "Environment file not found. Run setup first."
        exit 1
    fi
    
    # Generate new credentials
    NEW_PASSWORD=$(generate_password 16)
    NEW_ENCRYPTION_KEY=$(generate_encryption_key 32)
    NEW_JWT_SECRET=$(generate_encryption_key 32)
    NEW_WEBHOOK_TOKEN=$(generate_encryption_key 24)
    
    # Backup current .env
    cp "$ENV_FILE" "$ENV_FILE.backup-$(date +%Y%m%d_%H%M%S)"
    
    # Update secrets in .env file safely
    safe_env_replace "N8N_BASIC_AUTH_PASSWORD" "$NEW_PASSWORD" "$ENV_FILE"
    safe_env_replace "N8N_ENCRYPTION_KEY" "$NEW_ENCRYPTION_KEY" "$ENV_FILE"
    safe_env_replace "N8N_JWT_SECRET" "$NEW_JWT_SECRET" "$ENV_FILE"
    safe_env_replace "N8N_WEBHOOK_TOKEN" "$NEW_WEBHOOK_TOKEN" "$ENV_FILE"
    
    print_success "New secrets generated and applied"
    print_success "New admin password: $NEW_PASSWORD"
    print_warning "Please save this password securely!"
    print_status "Restart services to apply changes: ./n8n.sh restart"
}

# Function to run security check
security_check() {
    print_header "=== Security Check ==="
    
    local issues=0
    
    # Check .env file permissions
    if [ -f "$ENV_FILE" ]; then
        local perms=$(stat -c "%a" "$ENV_FILE" 2>/dev/null || stat -f "%A" "$ENV_FILE" 2>/dev/null)
        if [ "$perms" = "600" ]; then
            print_success ".env file permissions: $perms (secure)"
        else
            print_warning ".env file permissions: $perms (recommended: 600)"
            ((issues++))
        fi
    fi
    
    # Check for weak passwords
    if [ -f "$ENV_FILE" ]; then
        while IFS= read -r line; do
            if [[ $line =~ ^[^#]*= ]]; then
                key=$(echo "$line" | cut -d'=' -f1)
                value=$(echo "$line" | cut -d'=' -f2-)
                
                case "$key" in
                    *PASSWORD*|*SECRET*|*TOKEN*|*KEY*)
                        if [[ "$value" == "" ]] || [[ "$value" == "CHANGE_"* ]] || [[ ${#value} -lt 12 ]]; then
                            print_warning "Weak/default value for: $key"
                            ((issues++))
                        fi
                        ;;
                esac
            fi
        done < "$ENV_FILE"
    fi
    
    if [ $issues -eq 0 ]; then
        print_success "Security check passed!"
    else
        print_warning "Found $issues security issues. Consider running: ./n8n.sh generate-secrets"
    fi
}

# Function to clean up
cleanup() {
    print_header "=== Cleanup ==="
    print_warning "This will remove all containers, images, and volumes!"
    print_warning "ALL DATA WILL BE LOST!"
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleanup cancelled"
        exit 0
    fi
    
    print_status "Stopping and removing all n8n containers..."
    docker-compose --env-file="$ENV_FILE" down -v --rmi all
    
    print_status "Removing data directories..."
    rm -rf data/
    
    print_success "Cleanup completed"
}

# Function to show help
show_help() {
    cat << EOF
N8N Docker Management Script

USAGE:
    ./n8n.sh <command> [options]

COMMANDS:
    setup               Initial setup with secure credentials
    start               Start n8n services
    stop                Stop n8n services  
    restart             Restart n8n services
    status              Show service status and health
    logs [service]      Show logs (n8n, redis, or all)
    
    backup              Create backup of data and configuration
    restore <file>      Restore from backup file
    
    update              Update n8n to latest version (with backup)
    generate-secrets    Generate new secure credentials
    security-check      Run security validation
    
    cleanup             Remove all containers and data (DESTRUCTIVE)
    help                Show this help message

EXAMPLES:
    ./n8n.sh setup              # First time setup
    ./n8n.sh start              # Start services
    ./n8n.sh logs n8n           # Show n8n logs only
    ./n8n.sh backup             # Create backup
    ./n8n.sh restore backup.tar.gz  # Restore from backup
    ./n8n.sh update             # Update to latest version

ACCESS:
    After starting, access n8n at: http://\${N8N_HOST:-0.0.0.0}:\${N8N_PORT:-5678}
    
    FIRST-TIME SETUP:
    - No login required - direct access to n8n interface
    - Create your admin account through n8n's setup wizard
    - Basic auth is disabled by default (recommended)
    
    ADVANCED: Enable basic auth by setting N8N_BASIC_AUTH_ACTIVE=true in .env

SECURITY:
    - Credentials are auto-generated securely
    - .env file is protected with 600 permissions
    - Regular security checks recommended
    - Use different credentials for production

EOF
}

# Main function
main() {
    local command="${1:-help}"
    
    # Load environment variables if .env exists (for all commands except setup)
    if [ "$command" != "setup" ] && [ -f "$ENV_FILE" ]; then
        load_env
    fi
    
    case "$command" in
        "setup")
            clear
            show_banner
            echo
            setup_environment
            ;;
        "start")
            start_services
            ;;
        "stop")
            stop_services
            ;;
        "restart")
            restart_services
            ;;
        "status")
            check_status
            ;;
        "logs")
            show_logs "$2"
            ;;
        "backup")
            create_backup
            ;;
        "restore")
            restore_backup "$2"
            ;;
        "update")
            update_n8n
            ;;
        "generate-secrets")
            generate_secrets
            ;;
        "security-check")
            security_check
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function
main "$@"
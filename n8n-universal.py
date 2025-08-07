#!/usr/bin/env python3

"""
N8N Universal Docker Management Script
Cross-platform script for Windows and Linux/macOS
"""

import os
import sys
import json
import platform
import subprocess
import secrets
import string
import time
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

# Colors for different platforms
class Colors:
    if platform.system() == "Windows":
        # Windows doesn't support ANSI colors in older terminals
        RED = GREEN = YELLOW = BLUE = PURPLE = CYAN = NC = ""
        # Try to enable ANSI colors on Windows 10+
        try:
            import colorama
            colorama.init()
            RED = '\033[0;31m'
            GREEN = '\033[0;32m'
            YELLOW = '\033[1;33m'
            BLUE = '\033[0;34m'
            PURPLE = '\033[0;35m'
            CYAN = '\033[0;36m'
            NC = '\033[0m'
        except ImportError:
            pass
    else:
        RED = '\033[0;31m'
        GREEN = '\033[0;32m'
        YELLOW = '\033[1;33m'
        BLUE = '\033[0;34m'
        PURPLE = '\033[0;35m'
        CYAN = '\033[0;36m'
        NC = '\033[0m'

class N8NManager:
    def __init__(self):
        self.script_dir = Path(__file__).parent.absolute()
        self.env_file = self.script_dir / ".env"
        self.compose_file = self.script_dir / "docker-compose.yml"
        self.log_dir = self.script_dir / "logs"
        self.backup_dir = self.script_dir / "backups"
        
        # Ensure directories exist
        self.log_dir.mkdir(exist_ok=True)
        self.backup_dir.mkdir(exist_ok=True)
        
        # Setup logging
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.log_file = self.log_dir / f"n8n-{timestamp}.log"
        
        # Docker compose command based on platform
        self.docker_compose_cmd = self._get_docker_compose_command()

    def _get_docker_compose_command(self) -> List[str]:
        """Get the appropriate docker compose command for the platform"""
        # Try docker compose (new) first, then docker-compose (old)
        try:
            subprocess.run(["docker", "compose", "version"], 
                         capture_output=True, check=True)
            return ["docker", "compose"]
        except (subprocess.CalledProcessError, FileNotFoundError):
            try:
                subprocess.run(["docker-compose", "version"], 
                             capture_output=True, check=True)
                return ["docker-compose"]
            except (subprocess.CalledProcessError, FileNotFoundError):
                raise RuntimeError("Neither 'docker compose' nor 'docker-compose' found")

    def print_status(self, message: str):
        """Print status message"""
        output = f"{Colors.BLUE}[INFO]{Colors.NC} {message}"
        print(output)
        self._log(output)

    def print_success(self, message: str):
        """Print success message"""
        output = f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}"
        print(output)
        self._log(output)

    def print_warning(self, message: str):
        """Print warning message"""
        output = f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}"
        print(output)
        self._log(output)

    def print_error(self, message: str):
        """Print error message"""
        output = f"{Colors.RED}[ERROR]{Colors.NC} {message}"
        print(output)
        self._log(output)

    def print_header(self, message: str):
        """Print header message"""
        output = f"{Colors.PURPLE}{message}{Colors.NC}"
        print(output)
        self._log(output)

    def _log(self, message: str):
        """Log message to file"""
        with open(self.log_file, "a", encoding="utf-8") as f:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            f.write(f"[{timestamp}] {message}\n")

    def show_banner(self):
        """Show ASCII banner"""
        banner = """
 ███▄    █  █    ██  ███▄    █ 
 ██ ▀█   █  ██  ▓██▒ ██ ▀█   █ 
▓██  ▀█ ██▒▓██  ▒██░▓██  ▀█ ██▒
▓██▒  ▐▌██▒▓▓█  ░██░▓██▒  ▐▌██▒
▒██░   ▓██░▒▒█████▓ ▒██░   ▓██░
░ ▒░   ▒ ▒ ░▒▓▒ ▒ ▒ ░ ▒░   ▒ ▒ 
░ ░░   ░ ▒░░░▒░ ░ ░ ░ ░░   ░ ▒░
   ░   ░ ░  ░░░ ░ ░    ░   ░ ░ 
         ░    ░              ░ 
        Universal Management
        """
        print(banner)

    def generate_password(self, length: int = 20) -> str:
        """Generate secure random password"""
        alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
        return ''.join(secrets.choice(alphabet) for _ in range(length))

    def generate_encryption_key(self, length: int = 32) -> str:
        """Generate secure encryption key"""
        return secrets.token_urlsafe(length)

    def check_dependencies(self):
        """Check if required dependencies are installed"""
        missing = []
        
        # Check Docker
        try:
            subprocess.run(["docker", "--version"], 
                         capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            missing.append("Docker")

        # Check Docker Compose
        try:
            subprocess.run(self.docker_compose_cmd + ["version"], 
                         capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            missing.append("Docker Compose")

        if missing:
            self.print_error(f"Missing required dependencies: {', '.join(missing)}")
            self.print_status("Please install the missing dependencies and try again")
            sys.exit(1)

        # Check if Docker daemon is running
        try:
            subprocess.run(["docker", "info"], 
                         capture_output=True, check=True)
        except subprocess.CalledProcessError:
            self.print_error("Docker daemon is not running. Please start Docker.")
            sys.exit(1)

    def load_env(self) -> Dict[str, str]:
        """Load environment variables from .env file"""
        env_vars = {}
        if self.env_file.exists():
            with open(self.env_file, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        env_vars[key] = value
        return env_vars

    def create_env_file(self):
        """Create .env file with secure defaults"""
        template_file = self.script_dir / ".env.template"
        
        if not template_file.exists():
            self.print_error("Template file .env.template not found!")
            self.print_status("Please ensure .env.template exists in the project directory")
            sys.exit(1)

        # Generate secure credentials
        admin_password = self.generate_password(16)
        encryption_key = self.generate_encryption_key(32)
        jwt_secret = self.generate_encryption_key(32)
        webhook_token = self.generate_encryption_key(24)
        db_password = self.generate_password(20)
        redis_password = self.generate_password(16)

        # Read template and replace placeholders
        with open(template_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Replace placeholders
        content = content.replace("__ADMIN_PASSWORD__", admin_password)
        content = content.replace("__ENCRYPTION_KEY__", encryption_key)
        content = content.replace("__JWT_SECRET__", jwt_secret)
        content = content.replace("__WEBHOOK_TOKEN__", webhook_token)
        content = content.replace("__DB_PASSWORD__", db_password)
        content = content.replace("__REDIS_PASSWORD__", redis_password)

        # Write .env file
        header = f"# Generated on {datetime.now()} by n8n-universal.py\n"
        header += "# Production-ready configuration with secure auto-generated credentials\n\n"
        
        with open(self.env_file, 'w', encoding='utf-8') as f:
            f.write(header + content)

        # Set secure permissions (Unix-like systems only)
        if platform.system() != "Windows":
            os.chmod(self.env_file, 0o600)

        self.print_success("Environment file created with secure auto-generated credentials")
        self.print_status("Basic authentication is DISABLED by default for first-time setup")
        self.print_status("Configure user accounts through n8n's web interface at http://localhost:5678")

    def setup_environment(self):
        """Setup initial environment"""
        self.print_header("=== Setting Up Environment ===")
        
        # Create data directories
        data_dirs = ["data/n8n", "data/redis", "data/postgres", "backups", "logs"]
        for dir_path in data_dirs:
            (self.script_dir / dir_path).mkdir(parents=True, exist_ok=True)

        # Create .env file if it doesn't exist
        if not self.env_file.exists():
            self.create_env_file()
        else:
            self.print_status("Environment file already exists")
            self.print_status("Run 'generate-secrets' command to regenerate credentials if needed")

        self.print_success("Environment setup completed")
        self.print_success("Ready to start n8n with: python n8n-universal.py start")

    def run_docker_compose(self, args: List[str], env_vars: Optional[Dict[str, str]] = None):
        """Run docker compose command with environment variables"""
        if env_vars is None:
            env_vars = self.load_env()
        
        # Prepare environment
        cmd_env = os.environ.copy()
        cmd_env.update(env_vars)
        
        cmd = self.docker_compose_cmd + ["--env-file", str(self.env_file)] + args
        
        try:
            result = subprocess.run(cmd, env=cmd_env, cwd=self.script_dir, check=True)
            return result
        except subprocess.CalledProcessError as e:
            self.print_error(f"Docker compose command failed: {' '.join(cmd)}")
            raise

    def start_services(self):
        """Start n8n services"""
        self.print_header("=== Starting N8N Services ===")
        
        self.check_dependencies()
        
        # Auto-create .env file if it doesn't exist
        if not self.env_file.exists():
            self.create_env_file()
        
        env_vars = self.load_env()
        
        self.print_status("Starting services with docker compose...")
        
        try:
            self.run_docker_compose(["up", "-d"], env_vars)
            self.print_success("Services started successfully")
            
            # Wait for health check
            time.sleep(10)
            self.print_status("Checking service health...")
            
            n8n_host = env_vars.get("N8N_HOST", "localhost")
            n8n_port = env_vars.get("N8N_PORT", "5678")
            n8n_url = f"http://{n8n_host}:{n8n_port}"
            
            # Check health (using curl if available, otherwise skip)
            try:
                import urllib.request
                urllib.request.urlopen(f"{n8n_url}/healthz", timeout=5)
                self.print_success("n8n is running and healthy!")
                self.print_success(f"Access your n8n instance at: {n8n_url}")
            except:
                self.print_warning("n8n may still be starting up. Check logs if needed.")
                
        except subprocess.CalledProcessError:
            self.print_error("Failed to start services")
            sys.exit(1)

    def stop_services(self):
        """Stop n8n services"""
        self.print_header("=== Stopping N8N Services ===")
        
        try:
            self.run_docker_compose(["down"])
            self.print_success("Services stopped successfully")
        except subprocess.CalledProcessError:
            self.print_error("Failed to stop services")
            sys.exit(1)

    def restart_services(self):
        """Restart n8n services"""
        self.print_header("=== Restarting N8N Services ===")
        self.stop_services()
        self.start_services()

    def show_logs(self, service: str = "all"):
        """Show service logs"""
        self.print_header("=== N8N Service Logs ===")
        
        if service == "all":
            self.run_docker_compose(["logs", "-f"])
        else:
            self.run_docker_compose(["logs", "-f", service])

    def check_status(self):
        """Check service status"""
        self.print_header("=== Service Status ===")
        
        env_vars = self.load_env()
        self.run_docker_compose(["ps"], env_vars)
        
        print()
        self.print_status("Health Check:")
        
        n8n_host = env_vars.get("N8N_HOST", "localhost")
        n8n_port = env_vars.get("N8N_PORT", "5678")
        n8n_url = f"http://{n8n_host}:{n8n_port}"
        
        try:
            import urllib.request
            urllib.request.urlopen(f"{n8n_url}/healthz", timeout=5)
            self.print_success("n8n is responding and healthy")
        except:
            self.print_warning("n8n is not responding or still starting")

    def create_backup(self):
        """Create backup of data and configuration"""
        self.print_header("=== Creating Backup ===")
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = self.backup_dir / f"n8n_backup_{timestamp}.tar.gz"
        
        self.print_status("Creating backup archive...")
        
        try:
            import tarfile
            with tarfile.open(backup_file, "w:gz") as tar:
                tar.add(self.script_dir / "data", arcname="data")
                if self.env_file.exists():
                    tar.add(self.env_file, arcname=".env")
            
            self.print_success(f"Backup created: {backup_file.name}")
            self.print_status(f"Backup location: {backup_file}")
        except Exception as e:
            self.print_error(f"Failed to create backup: {e}")
            sys.exit(1)

    def show_help(self):
        """Show help message"""
        help_text = """
N8N Universal Docker Management Script
Cross-platform script for Windows and Linux/macOS

USAGE:
    python n8n-universal.py <command> [options]

COMMANDS:
    setup               Initial setup with secure credentials
    start               Start n8n services  
    stop                Stop n8n services
    restart             Restart n8n services
    status              Show service status and health
    logs [service]      Show logs (n8n, redis, postgres, or all)
    
    backup              Create backup of data and configuration
    
    help                Show this help message

EXAMPLES:
    python n8n-universal.py setup      # First time setup
    python n8n-universal.py start      # Start services
    python n8n-universal.py logs n8n   # Show n8n logs only
    python n8n-universal.py backup     # Create backup

ACCESS:
    After starting, access n8n at: http://localhost:5678
    
    FIRST-TIME SETUP:
    - No login required - direct access to n8n interface
    - Create your admin account through n8n's setup wizard
    - Basic auth is disabled by default (recommended)

DATABASES:
    This setup includes:
    - PostgreSQL database for production-ready data storage
    - Redis for caching and queue management
    - Automatic health checks and dependency management

SECURITY:
    - Credentials are auto-generated securely
    - .env file is protected (Unix systems)
    - Regular security checks recommended
    - Use different credentials for production
        """
        print(help_text)

def main():
    parser = argparse.ArgumentParser(description="N8N Universal Docker Manager")
    parser.add_argument("command", nargs="?", default="help", 
                       help="Command to execute")
    parser.add_argument("service", nargs="?", default="all",
                       help="Service name for logs command")
    
    args = parser.parse_args()
    
    manager = N8NManager()
    
    try:
        if args.command == "setup":
            os.system('cls' if platform.system() == 'Windows' else 'clear')
            manager.show_banner()
            print()
            manager.setup_environment()
        elif args.command == "start":
            manager.start_services()
        elif args.command == "stop":
            manager.stop_services()
        elif args.command == "restart":
            manager.restart_services()
        elif args.command == "status":
            manager.check_status()
        elif args.command == "logs":
            manager.show_logs(args.service)
        elif args.command == "backup":
            manager.create_backup()
        elif args.command == "help":
            manager.show_help()
        else:
            manager.print_error(f"Unknown command: {args.command}")
            manager.show_help()
            sys.exit(1)
            
    except KeyboardInterrupt:
        manager.print_status("Operation cancelled by user")
        sys.exit(0)
    except Exception as e:
        manager.print_error(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
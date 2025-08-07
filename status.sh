#!/bin/bash

# n8n Stack Status Check Script
# Enhanced version with comprehensive health checks

echo "🚀 n8n Stack Status Check"
echo "========================="
echo

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running"
    exit 1
fi

# Check containers
echo "📦 Container Status:"
docker-compose ps --format table

echo
echo "🔗 Service Health:"

# Check each service
services=("n8n-postgres" "n8n-redis" "n8n")
for service in "${services[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "^$service$"; then
        health=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "no-health")
        status=$(docker inspect --format='{{.State.Status}}' "$service")
        
        if [[ "$status" == "running" ]]; then
            if [[ "$health" == "healthy" ]]; then
                echo "✅ $service: Running & Healthy"
            elif [[ "$health" == "no-health" ]]; then
                echo "🟡 $service: Running (no health check)"
            else
                echo "⚠️  $service: Running but $health"
            fi
        else
            echo "❌ $service: $status"
        fi
    else
        echo "❌ $service: Not found"
    fi
done

echo
echo "🌐 Network Connectivity:"

# Test internal connectivity if n8n is running
if docker ps --format "{{.Names}}" | grep -q "^n8n$"; then
    if docker exec n8n ping -c 1 postgres >/dev/null 2>&1; then
        echo "✅ n8n → postgres: Connected"
    else
        echo "❌ n8n → postgres: Failed"
    fi
    
    if docker exec n8n ping -c 1 redis >/dev/null 2>&1; then
        echo "✅ n8n → redis: Connected"
    else
        echo "❌ n8n → redis: Failed"
    fi
fi

echo
echo "🖥️  Service Endpoints:"

# Check service endpoints
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 | grep -q "200"; then
    echo "✅ n8n Web UI: http://localhost:5678 (HTTP 200)"
else
    echo "❌ n8n Web UI: http://localhost:5678 (Not accessible)"
fi

if docker exec n8n-postgres pg_isready -U n8n -d n8n >/dev/null 2>&1; then
    echo "✅ PostgreSQL: localhost:5432 (Ready)"
else
    echo "❌ PostgreSQL: localhost:5432 (Not ready)"
fi

if docker exec n8n-redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
    echo "✅ Redis: localhost:6379 (Connected)"
else
    echo "❌ Redis: localhost:6379 (Not accessible)"
fi

echo
echo "💾 Database Status:"

# Check database tables
if docker exec n8n-postgres psql -U n8n -d n8n -c "\dt" 2>/dev/null | grep -q "workflow_entity"; then
    table_count=$(docker exec n8n-postgres psql -U n8n -d n8n -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | tr -d ' ')
    echo "✅ PostgreSQL Tables: $table_count tables found"
else
    echo "⚠️  PostgreSQL: No n8n tables found (migrations may be pending)"
fi

# Check Redis info
if redis_info=$(docker exec n8n-redis redis-cli info server 2>/dev/null); then
    redis_version=$(echo "$redis_info" | grep "redis_version" | cut -d: -f2 | tr -d '\r')
    echo "✅ Redis Version: $redis_version"
else
    echo "❌ Redis: Unable to get info"
fi

echo
echo "📊 Resource Usage:"

# Show resource usage
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | head -4

echo
echo "🔧 Quick Commands:"
echo "  Start:   docker-compose up -d"
echo "  Stop:    docker-compose down"
echo "  Logs:    docker-compose logs -f"
echo "  Backup:  ./backup.sh"
echo "  Status:  ./status.sh"
echo
echo "✨ Stack Status: $(if docker-compose ps -q | xargs docker inspect --format='{{.State.Status}}' | grep -q '^running$'; then echo 'RUNNING'; else echo 'STOPPED/PARTIAL'; fi)"
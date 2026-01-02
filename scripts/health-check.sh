#!/bin/bash

# =================================================================
# Anonymous Torrent Stack - Health Check Monitor
# =================================================================
# This script monitors the health of Gluetun and qBittorrent
# Usage: ./scripts/health-check.sh
# For continuous monitoring: watch -n 30 ./scripts/health-check.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="health-check.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

log_message() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}

# Check container status
check_container_status() {
    local container_name=$1

    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "running"
    elif docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "stopped"
    else
        echo "missing"
    fi
}

# Check container health
check_container_health() {
    local container_name=$1

    health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "none")
    echo "$health"
}

# Main health check
print_header "Health Check - $(date '+%Y-%m-%d %H:%M:%S')"

# Check Gluetun
print_info "Checking Gluetun container..."
GLUETUN_STATUS=$(check_container_status "gluetun")

if [ "$GLUETUN_STATUS" = "running" ]; then
    print_success "Gluetun is running"

    # Check health status
    GLUETUN_HEALTH=$(check_container_health "gluetun")

    if [ "$GLUETUN_HEALTH" = "healthy" ]; then
        print_success "Gluetun is healthy"
        log_message "Gluetun: healthy"
    elif [ "$GLUETUN_HEALTH" = "unhealthy" ]; then
        print_error "Gluetun is unhealthy"
        log_message "Gluetun: unhealthy"
        echo -e "${YELLOW}Recent logs:${NC}"
        docker logs --tail 20 gluetun
    elif [ "$GLUETUN_HEALTH" = "starting" ]; then
        print_warning "Gluetun is still starting up"
        log_message "Gluetun: starting"
    else
        print_warning "Gluetun health status unknown"
        log_message "Gluetun: unknown health status"
    fi

    # Check VPN connection
    print_info "Checking VPN connection..."
    VPN_IP=$(curl -s --max-time 5 http://localhost:8000/v1/publicip/ip 2>/dev/null || echo "")

    if [ -n "$VPN_IP" ]; then
        print_success "VPN connected - IP: $VPN_IP"
        log_message "VPN IP: $VPN_IP"
    else
        print_error "Cannot connect to Gluetun control server"
        log_message "VPN: connection failed"
    fi

elif [ "$GLUETUN_STATUS" = "stopped" ]; then
    print_error "Gluetun is stopped"
    log_message "Gluetun: stopped"
    echo ""
    print_info "Restart with: docker start gluetun"
else
    print_error "Gluetun container is missing"
    log_message "Gluetun: missing"
    echo ""
    print_info "Start with: docker compose up -d"
fi

echo ""

# Check qBittorrent
print_info "Checking qBittorrent container..."
QBIT_STATUS=$(check_container_status "qbittorrent")

if [ "$QBIT_STATUS" = "running" ]; then
    print_success "qBittorrent is running"
    log_message "qBittorrent: running"

    # Check WebUI accessibility
    print_info "Checking WebUI accessibility..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:8080 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "WebUI is accessible at http://localhost:8080"
        log_message "qBittorrent WebUI: accessible"
    else
        print_warning "WebUI returned HTTP $HTTP_CODE"
        log_message "qBittorrent WebUI: HTTP $HTTP_CODE"
    fi

elif [ "$QBIT_STATUS" = "stopped" ]; then
    print_error "qBittorrent is stopped"
    log_message "qBittorrent: stopped"
    echo ""
    print_info "Restart with: docker start qbittorrent"
else
    print_error "qBittorrent container is missing"
    log_message "qBittorrent: missing"
    echo ""
    print_info "Start with: docker compose up -d"
fi

echo ""

# Check Docker resources
print_info "Checking resource usage..."
echo ""

docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" \
    gluetun qbittorrent 2>/dev/null || print_warning "Could not get resource stats"

echo ""

# Check disk space
print_info "Checking disk space for downloads..."
DOWNLOADS_PATH="./data/downloads"

if [ -d "$DOWNLOADS_PATH" ]; then
    DISK_USAGE=$(df -h "$DOWNLOADS_PATH" | awk 'NR==2 {print $5}' | sed 's/%//')
    DISK_AVAIL=$(df -h "$DOWNLOADS_PATH" | awk 'NR==2 {print $4}')

    echo -e "  Used: ${DISK_USAGE}%"
    echo -e "  Available: ${DISK_AVAIL}"

    if [ "$DISK_USAGE" -ge 90 ]; then
        print_error "Disk space is critically low (${DISK_USAGE}%)"
        log_message "Disk: critically low ${DISK_USAGE}%"
    elif [ "$DISK_USAGE" -ge 75 ]; then
        print_warning "Disk space is running low (${DISK_USAGE}%)"
        log_message "Disk: low ${DISK_USAGE}%"
    else
        print_success "Disk space is sufficient (${DISK_USAGE}% used)"
    fi
else
    print_warning "Downloads directory not found"
fi

echo ""

# Summary
print_header "Summary"

ALL_OK=true

if [ "$GLUETUN_STATUS" != "running" ] || [ "$GLUETUN_HEALTH" = "unhealthy" ]; then
    ALL_OK=false
fi

if [ "$QBIT_STATUS" != "running" ]; then
    ALL_OK=false
fi

if [ "$ALL_OK" = true ]; then
    print_success "All systems operational"
    log_message "Status: all systems operational"
else
    print_error "Some issues detected"
    log_message "Status: issues detected"
    echo ""
    print_info "Check logs with: docker compose logs"
    print_info "View recent health checks: cat $LOG_FILE"
fi

echo ""
print_info "Log file: $LOG_FILE"

# Exit with appropriate code
if [ "$ALL_OK" = true ]; then
    exit 0
else
    exit 1
fi

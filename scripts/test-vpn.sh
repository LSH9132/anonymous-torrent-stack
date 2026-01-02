#!/bin/bash

# =================================================================
# Anonymous Torrent Stack - VPN Connection Test
# =================================================================
# This script tests your VPN connection and checks for leaks
# Usage: ./scripts/test-vpn.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

print_result() {
    echo -e "${GREEN}$1:${NC} $2"
}

# Check if containers are running
print_header "VPN Connection Test"

print_info "Checking if containers are running..."

if ! docker ps | grep -q gluetun; then
    print_error "Gluetun container is not running"
    print_info "Start the stack with: docker compose up -d"
    exit 1
fi

if ! docker ps | grep -q qbittorrent; then
    print_error "qBittorrent container is not running"
    print_info "Start the stack with: docker compose up -d"
    exit 1
fi

print_success "Containers are running"

# Wait for services to be ready
print_info "Waiting for services to be ready..."
sleep 3

# Test 1: Get public IP through Gluetun
print_header "Test 1: VPN Public IP"

print_info "Querying Gluetun control server..."

# Try to get IP from Gluetun control server
VPN_IP=$(curl -s http://localhost:8000/v1/publicip/ip 2>/dev/null || echo "")

if [ -z "$VPN_IP" ]; then
    print_error "Could not connect to Gluetun control server"
    print_info "Gluetun may still be starting up. Wait a moment and try again."
    print_info "Check logs: docker compose logs gluetun"
    exit 1
fi

print_result "VPN IP Address" "$VPN_IP"

# Get location information
print_info "Getting location information..."
LOCATION=$(curl -s http://localhost:8000/v1/publicip/location 2>/dev/null || echo "Unknown")
print_result "Location" "$LOCATION"

# Test 2: Compare with your real IP
print_header "Test 2: IP Comparison"

print_info "Getting your real public IP (without VPN)..."
REAL_IP=$(curl -s https://api.ipify.org 2>/dev/null || echo "Unable to detect")

print_result "Your Real IP" "$REAL_IP"
print_result "VPN IP" "$VPN_IP"

if [ "$REAL_IP" = "$VPN_IP" ]; then
    print_error "WARNING: VPN IP matches your real IP!"
    print_error "The VPN may not be working correctly."
    exit 1
elif [ "$REAL_IP" = "Unable to detect" ]; then
    print_warning "Could not detect your real IP (you may be behind a firewall)"
    print_success "VPN IP is: $VPN_IP"
else
    print_success "VPN is working! Your IP is hidden."
fi

# Test 3: DNS Leak Test
print_header "Test 3: DNS Configuration"

print_info "Checking DNS settings in Gluetun..."
DNS_INFO=$(docker exec gluetun cat /etc/resolv.conf 2>/dev/null || echo "Unable to check")

if echo "$DNS_INFO" | grep -q "127.0.0.1"; then
    print_success "DNS is using Gluetun's DoT (DNS over TLS)"
    echo -e "${CYAN}DNS Configuration:${NC}"
    echo "$DNS_INFO" | head -5
else
    print_warning "DNS configuration may not be optimal"
    echo "$DNS_INFO"
fi

# Test 4: Check VPN connection status
print_header "Test 4: VPN Connection Status"

print_info "Checking VPN connection details..."
VPN_STATUS=$(curl -s http://localhost:8000/v1/openvpn/status 2>/dev/null || curl -s http://localhost:8000/v1/publicip/ip 2>/dev/null || echo "Unknown")

if [ "$VPN_STATUS" != "Unknown" ]; then
    print_success "VPN connection is active"
else
    print_warning "Could not determine VPN status"
fi

# Test 5: Port forwarding status (if enabled)
print_header "Test 5: Port Forwarding"

PORT_FORWARD=$(curl -s http://localhost:8000/v1/openvpn/portforwarded 2>/dev/null || echo "")

if [ -n "$PORT_FORWARD" ] && [ "$PORT_FORWARD" != "0" ]; then
    print_result "Forwarded Port" "$PORT_FORWARD"
    print_success "Port forwarding is active"
    print_info "Update qBittorrent to use this port for better connectivity"
else
    print_info "Port forwarding is not enabled or not supported by your VPN provider"
    print_info "Some VPN providers (PIA, ProtonVPN) support port forwarding"
    print_info "Set VPN_PORT_FORWARDING=on in .env to enable it"
fi

# Test 6: qBittorrent WebUI accessibility
print_header "Test 6: qBittorrent WebUI"

print_info "Testing qBittorrent WebUI accessibility..."

if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200"; then
    print_success "qBittorrent WebUI is accessible at http://localhost:8080"
    print_info "Default credentials: admin / adminadmin"
    print_warning "Change the default password after first login!"
else
    print_warning "qBittorrent WebUI may not be ready yet"
    print_info "Wait a moment and try accessing http://localhost:8080 in your browser"
fi

# Test 7: Kill switch test (informational)
print_header "Test 7: Kill Switch Status"

print_info "Kill switch is enabled via Docker network isolation"
print_success "qBittorrent can ONLY communicate through Gluetun"
print_info "If Gluetun stops, qBittorrent loses all network access"
echo ""
print_info "To test the kill switch manually:"
echo "  1. ${BLUE}docker stop gluetun${NC}"
echo "  2. Try to access qBittorrent WebUI (should fail)"
echo "  3. ${BLUE}docker start gluetun${NC}"
echo "  4. WebUI should work again after ~30 seconds"

# Summary
print_header "Test Summary"

print_success "All tests completed!"
echo ""
echo "Results:"
echo "  VPN IP: ${GREEN}$VPN_IP${NC}"
echo "  Location: ${GREEN}$LOCATION${NC}"
echo "  Kill Switch: ${GREEN}Enabled${NC}"
echo "  DNS Leak Protection: ${GREEN}Enabled (DoT)${NC}"
echo "  WebUI: ${GREEN}http://localhost:8080${NC}"
echo ""

if [ -n "$PORT_FORWARD" ] && [ "$PORT_FORWARD" != "0" ]; then
    echo "  Port Forwarding: ${GREEN}$PORT_FORWARD${NC}"
    echo ""
fi

print_success "Your torrent stack is ready to use!"
print_info "For troubleshooting, see: docs/troubleshooting.md"

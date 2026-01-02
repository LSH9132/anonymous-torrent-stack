#!/bin/bash

# =================================================================
# Anonymous Torrent Stack - Setup Script
# =================================================================
# This script automates the initial setup process
# Usage: ./scripts/setup.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Check if running from project root
if [ ! -f "docker-compose.yml" ]; then
    print_error "Please run this script from the project root directory"
    print_info "Example: ./scripts/setup.sh"
    exit 1
fi

print_header "Anonymous Torrent Stack - Setup"

# Check prerequisites
print_info "Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    print_info "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi
print_success "Docker is installed"

# Check Docker Compose
if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed"
    print_info "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi
print_success "Docker Compose is installed"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running"
    print_info "Please start Docker and try again"
    exit 1
fi
print_success "Docker daemon is running"

# Create .env file if it doesn't exist
print_info "Setting up environment configuration..."

if [ -f ".env" ]; then
    print_warning ".env file already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing .env file"
    else
        cp .env.example .env
        print_success "Created new .env file from template"
    fi
else
    cp .env.example .env
    print_success "Created .env file from template"
fi

# Get user's UID and GID
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

# Update PUID and PGID in .env
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^PUID=.*/PUID=${CURRENT_UID}/" .env
    sed -i '' "s/^PGID=.*/PGID=${CURRENT_GID}/" .env
else
    # Linux
    sed -i "s/^PUID=.*/PUID=${CURRENT_UID}/" .env
    sed -i "s/^PGID=.*/PGID=${CURRENT_GID}/" .env
fi
print_success "Set PUID=${CURRENT_UID} and PGID=${CURRENT_GID}"

# Detect timezone
if command -v timedatectl &> /dev/null; then
    DETECTED_TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "UTC")
elif [ -f /etc/timezone ]; then
    DETECTED_TZ=$(cat /etc/timezone)
else
    DETECTED_TZ="UTC"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|^TZ=.*|TZ=${DETECTED_TZ}|" .env
else
    sed -i "s|^TZ=.*|TZ=${DETECTED_TZ}|" .env
fi
print_success "Set timezone to ${DETECTED_TZ}"

# Interactive VPN configuration
print_header "VPN Configuration"

echo "This setup wizard will help you configure your VPN."
echo ""
echo "Supported VPN providers include:"
echo "  - Mullvad (recommended for privacy)"
echo "  - ProtonVPN"
echo "  - NordVPN"
echo "  - Private Internet Access (PIA)"
echo "  - ExpressVPN"
echo "  - And 55+ more providers"
echo "  - Custom (any VPN with config files)"
echo ""

read -p "Enter your VPN provider name (or 'custom' for custom config): " VPN_PROVIDER
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^VPN_PROVIDER=.*/VPN_PROVIDER=${VPN_PROVIDER}/" .env
else
    sed -i "s/^VPN_PROVIDER=.*/VPN_PROVIDER=${VPN_PROVIDER}/" .env
fi

echo ""
read -p "Select VPN protocol (wireguard/openvpn) [wireguard]: " VPN_TYPE
VPN_TYPE=${VPN_TYPE:-wireguard}
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^VPN_TYPE=.*/VPN_TYPE=${VPN_TYPE}/" .env
else
    sed -i "s/^VPN_TYPE=.*/VPN_TYPE=${VPN_TYPE}/" .env
fi

print_success "VPN configuration saved"

# Port configuration
print_header "Port Configuration"

echo "qBittorrent WebUI port configuration:"
echo "  1. localhost:8080 (recommended - local access only)"
echo "  2. 8080:8080 (network accessible - requires authentication)"
echo ""

read -p "Select option [1]: " PORT_OPTION
PORT_OPTION=${PORT_OPTION:-1}

if [ "$PORT_OPTION" = "2" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|^QBITTORRENT_PORT=.*|QBITTORRENT_PORT=8080:8080|" .env
    else
        sed -i "s|^QBITTORRENT_PORT=.*|QBITTORRENT_PORT=8080:8080|" .env
    fi
    print_success "WebUI will be accessible on your network at port 8080"
    print_warning "Make sure to change the default password after first login!"
else
    print_success "WebUI will be accessible at http://localhost:8080"
fi

# Final instructions
print_header "Setup Complete!"

echo "Next steps:"
echo ""
echo "1. Edit the .env file and add your VPN credentials:"
echo "   ${BLUE}nano .env${NC} or ${BLUE}vim .env${NC}"
echo ""

if [ "$VPN_TYPE" = "wireguard" ]; then
    if [ "$VPN_PROVIDER" = "custom" ]; then
        echo "   For custom WireGuard:"
        echo "   - Place your wg0.conf in: config/vpn/wireguard/"
    else
        echo "   For $VPN_PROVIDER with WireGuard:"
        echo "   - Set WIREGUARD_PRIVATE_KEY"
        echo "   - Set WIREGUARD_ADDRESSES"
        echo "   - Optionally set SERVER_COUNTRIES"
    fi
else
    if [ "$VPN_PROVIDER" = "custom" ]; then
        echo "   For custom OpenVPN:"
        echo "   - Place your .ovpn file in: config/vpn/openvpn/"
        echo "   - Set OPENVPN_CUSTOM_CONFIG=/gluetun/custom/your-file.conf"
    else
        echo "   For $VPN_PROVIDER with OpenVPN:"
        echo "   - Set OPENVPN_USER"
        echo "   - Set OPENVPN_PASSWORD"
        echo "   - Optionally set SERVER_COUNTRIES"
    fi
fi

echo ""
echo "2. See provider-specific guides in docs/vpn-providers/"
echo ""
echo "3. Start the stack:"
echo "   ${BLUE}docker compose up -d${NC}"
echo ""
echo "4. Check the logs:"
echo "   ${BLUE}docker compose logs -f${NC}"
echo ""
echo "5. Test your VPN connection:"
echo "   ${BLUE}./scripts/test-vpn.sh${NC}"
echo ""
echo "6. Access qBittorrent WebUI:"
echo "   ${BLUE}http://localhost:8080${NC}"
echo "   Default credentials: admin / adminadmin"
echo "   ${RED}(Change these immediately after first login!)${NC}"
echo ""

print_success "Setup complete! Review docs/setup-guide.md for detailed instructions."

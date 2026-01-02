# Advanced Configuration Guide

This guide covers advanced topics for power users.

## Table of Contents

- [Port Forwarding](#port-forwarding)
- [Custom DNS Configuration](#custom-dns-configuration)
- [Multiple VPN Configurations](#multiple-vpn-configurations)
- [Network Configuration](#network-configuration)
- [Performance Tuning](#performance-tuning)
- [Extending the Stack](#extending-the-stack)
- [Monitoring and Logging](#monitoring-and-logging)
- [Security Hardening](#security-hardening)

## Port Forwarding

### Supported Providers

Port forwarding improves torrent connectivity by allowing incoming connections:

- **Private Internet Access (PIA)** ✅
- **ProtonVPN** ✅
- **AirVPN** ✅
- **Perfect Privacy** ✅
- **Mullvad** ❌ (discontinued 2023)
- **NordVPN** ❌
- **ExpressVPN** ❌

### Enable Port Forwarding

**Step 1: Configure .env**

```bash
VPN_PORT_FORWARDING=on
VPN_PORT_FORWARDING_PROVIDER=private internet access
```

**Step 2: Restart**

```bash
docker compose restart gluetun
```

**Step 3: Get Forwarded Port**

```bash
curl http://localhost:8000/v1/openvpn/portforwarded
# Returns: 12345 (example)
```

**Step 4: Configure qBittorrent**

1. Open WebUI: http://localhost:8080
2. Go to: Tools → Options → Connection
3. Set "Listening Port" to the forwarded port number
4. Uncheck "Use UPnP / NAT-PMP port forwarding from my router"
5. Click "Save"

### Automatic Port Update

Create a script to automatically update qBittorrent's port:

```bash
#!/bin/bash
# scripts/update-port.sh

FORWARDED_PORT=$(curl -s http://localhost:8000/v1/openvpn/portforwarded)

if [ "$FORWARDED_PORT" != "0" ] && [ -n "$FORWARDED_PORT" ]; then
    echo "Forwarded port: $FORWARDED_PORT"
    # Update qBittorrent via API (requires authentication)
    # See qBittorrent WebAPI documentation
fi
```

### Troubleshooting Port Forwarding

**Port shows as 0:**
```bash
# Restart Gluetun
docker compose restart gluetun

# Check logs
docker compose logs gluetun | grep -i "port forward"
```

**Port changes frequently:**
- Some providers rotate ports periodically
- Use automation script to keep qBittorrent updated

## Custom DNS Configuration

### DNS Providers

Available DoT (DNS over TLS) providers:

```bash
# Cloudflare (default, privacy-focused)
DOT_PROVIDERS=cloudflare

# Quad9 (security-focused, blocks malware)
DOT_PROVIDERS=quad9

# Google (performance-focused)
DOT_PROVIDERS=google

# Multiple providers (fallback)
DOT_PROVIDERS=cloudflare,quad9
```

### Advanced DNS Options

**Block Malicious Domains:**
```bash
BLOCK_MALICIOUS=on  # Recommended
```

**Block Surveillance Domains:**
```bash
BLOCK_SURVEILLANCE=on  # May break some sites
```

**Block Ad Domains:**
```bash
BLOCK_ADS=on  # May break some sites
```

**IPv6 DNS:**
```bash
DOT_IPV6=on  # Enable if you use IPv6
```

**DNS Caching:**
```bash
DOT_CACHING=on  # Improves performance (default)
```

### Custom DNS Servers

To use your own DNS servers (bypasses DoT):

```bash
# Disable DoT (not recommended for privacy)
DOT=off

# Then add custom DNS in docker-compose.yml
# Under gluetun service:
dns:
  - 1.1.1.1
  - 8.8.8.8
```

## Multiple VPN Configurations

### Method 1: Multiple .env Files

```bash
# Create provider-specific .env files
cp .env .env.mullvad
cp .env .env.protonvpn

# Edit each with different credentials
nano .env.mullvad
nano .env.protonvpn

# Switch providers
cp .env.mullvad .env
docker compose restart
```

### Method 2: Docker Compose Profiles

Add profiles to docker-compose.yml:

```yaml
services:
  gluetun-mullvad:
    image: qmcgaw/gluetun:latest
    # ... mullvad config ...
    profiles: ["mullvad"]

  gluetun-protonvpn:
    image: qmcgaw/gluetun:latest
    # ... protonvpn config ...
    profiles: ["protonvpn"]

  qbittorrent:
    # ... config ...
    network_mode: "service:${ACTIVE_VPN:-gluetun-mullvad}"
```

Start with specific profile:
```bash
docker compose --profile mullvad up -d
```

### Method 3: Multiple Stacks

Run completely separate stacks:

```bash
# Stack 1: Mullvad
cd ~/torrent-mullvad
docker compose up -d

# Stack 2: ProtonVPN
cd ~/torrent-protonvpn
docker compose up -d
```

Use different ports for each:
```bash
# Stack 1
QBITTORRENT_PORT=127.0.0.1:8080:8080

# Stack 2
QBITTORRENT_PORT=127.0.0.1:9080:8080
```

## Network Configuration

### Custom Network Subnet

Edit docker-compose.yml:

```yaml
networks:
  vpn_network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.30.0.0/16
          gateway: 172.30.0.1
```

Update firewall subnet:
```bash
FIREWALL_OUTBOUND_SUBNETS=172.30.0.0/16
```

### Allow Local Network Access

To access qBittorrent WebUI from LAN:

```bash
# Get your local network subnet
ip route | grep -v default
# Example output: 192.168.1.0/24

# Add to .env
FIREWALL_OUTBOUND_SUBNETS=192.168.1.0/24,172.20.0.0/16

# Change port binding
QBITTORRENT_PORT=8080:8080  # Remove 127.0.0.1

# Restart
docker compose restart
```

Access from LAN devices:
```
http://YOUR_COMPUTER_IP:8080
```

### IPv6 Support

Enable IPv6 if your VPN provider supports it:

```bash
# In .env (if using WireGuard with IPv6 addresses)
WIREGUARD_ADDRESSES=10.x.x.x/32,fc00::/128

# Enable IPv6 DNS
DOT_IPV6=on
```

## Performance Tuning

### Resource Limits

Add resource limits to docker-compose.yml:

```yaml
services:
  gluetun:
    # ...existing config...
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 256M
        reservations:
          cpus: '0.5'
          memory: 128M

  qbittorrent:
    # ...existing config...
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
```

### qBittorrent Performance Settings

In qBittorrent WebUI (Tools → Options):

**Connection:**
- Global maximum connections: 500
- Maximum connections per torrent: 100
- Upload slots per torrent: 4

**Speed:**
- Alternative rate limits (optional for daytime limiting)
- Schedule: Configure quiet hours

**BitTorrent:**
- Enable DHT, PEX, and Local Peer Discovery
- Encryption: Require encryption
- Anonymous mode: Enable

**Advanced:**
- Network interface: Leave empty (uses VPN)
- Enable embedded tracker: Disable
- Resolve peer countries: Enable (optional)

### Disk I/O Optimization

```yaml
volumes:
  - ./data/downloads:/downloads:rw,Z  # SELinux
  - ./data/downloads:/downloads:delegated  # macOS performance
```

### DNS Caching

Already enabled by default:
```bash
DOT_CACHING=on
```

## Extending the Stack

### Add Jackett (Torrent Indexer)

Add to docker-compose.yml:

```yaml
services:
  jackett:
    image: lscr.io/linuxserver/jackett:latest
    container_name: jackett
    network_mode: "service:gluetun"  # Routes through VPN
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./config/jackett:/config
      - ./data/downloads:/downloads
    restart: unless-stopped
    depends_on:
      gluetun:
        condition: service_healthy
```

Expose Jackett port through Gluetun:

```yaml
gluetun:
  ports:
    - "${QBITTORRENT_PORT:-127.0.0.1:8080}:8080"
    - "127.0.0.1:9117:9117"  # Jackett
```

Access: http://localhost:9117

### Add Radarr/Sonarr (Media Automation)

Similar pattern:

```yaml
services:
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    network_mode: "service:gluetun"
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./config/radarr:/config
      - ./data/downloads:/downloads
      - /path/to/movies:/movies
    restart: unless-stopped
    depends_on:
      gluetun:
        condition: service_healthy
```

Add port to Gluetun:
```yaml
- "127.0.0.1:7878:7878"  # Radarr
```

### Add Prometheus Monitoring

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./config/prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    ports:
      - "127.0.0.1:9090:9090"
    restart: unless-stopped
    networks:
      - vpn_network

volumes:
  prometheus_data:
```

## Monitoring and Logging

### Structured Logging

Configure log level:

```bash
# In .env
LOG_LEVEL=info  # Options: debug, info, warning, error
```

View logs with timestamps:
```bash
docker compose logs -t -f
```

### Log Rotation

Configure in Docker daemon.json:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

### Health Check Monitoring

**Continuous monitoring:**
```bash
watch -n 30 ./scripts/health-check.sh
```

**Cron job:**
```bash
# Add to crontab
*/30 * * * * cd /path/to/project && ./scripts/health-check.sh >> health-check.log 2>&1
```

**Alert on failure:**
```bash
#!/bin/bash
# scripts/health-check-alert.sh

if ! ./scripts/health-check.sh; then
    echo "Health check failed!" | mail -s "VPN Stack Alert" your@email.com
    # Or use ntfy.sh, Pushover, etc.
fi
```

### Prometheus Metrics

Gluetun exposes metrics:

```bash
curl http://localhost:8000/v1/publicip/ip
curl http://localhost:8000/metrics
```

## Security Hardening

### Restrict WebUI Access

**Method 1: Localhost Only (Default)**
```bash
QBITTORRENT_PORT=127.0.0.1:8080:8080
```

**Method 2: Specific IP**
```bash
QBITTORRENT_PORT=192.168.1.100:8080:8080
```

**Method 3: Reverse Proxy**

Use nginx/Caddy with authentication:

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "127.0.0.1:80:80"
    volumes:
      - ./config/nginx:/etc/nginx/conf.d
    networks:
      - vpn_network
```

nginx config:
```nginx
server {
    listen 80;
    location / {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://gluetun:8080;
    }
}
```

### Firewall Rules

**Restrict to specific subnets:**
```bash
FIREWALL_OUTBOUND_SUBNETS=192.168.1.0/24
```

**Allow specific ports:**
```bash
FIREWALL_INPUT_PORTS=8080,9117
```

### Regular Key Rotation

**For WireGuard:**
- Generate new key monthly with VPN provider
- Update .env
- Restart: `docker compose restart gluetun`

**For OpenVPN:**
- Some providers rotate automatically
- Check provider documentation

### Disable Unnecessary Features

```bash
# Disable HTTP proxy (if not needed)
HTTPPROXY=off

# Disable Shadowsocks (if not needed)
SHADOWSOCKS=off

# Minimize logging
LOG_LEVEL=warning
```

## Docker Compose Overrides

Create `docker-compose.override.yml` for local customizations:

```yaml
version: "3.8"

services:
  gluetun:
    environment:
      - CUSTOM_VAR=value

  qbittorrent:
    environment:
      - WEBUI_PORT=9090
```

This file is git-ignored by default and won't be overwritten.

## Backup and Restore

### Backup

```bash
#!/bin/bash
# scripts/backup.sh

BACKUP_DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="backups/$BACKUP_DATE"

mkdir -p "$BACKUP_DIR"

# Backup configuration
cp .env "$BACKUP_DIR/"
cp -r config "$BACKUP_DIR/"

# Backup qBittorrent settings only (not downloads)
tar -czf "$BACKUP_DIR/qbittorrent-config.tar.gz" config/qbittorrent/

echo "Backup created: $BACKUP_DIR"
```

### Restore

```bash
#!/bin/bash
# scripts/restore.sh

BACKUP_DIR=$1

if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: ./restore.sh backups/20240315-120000"
    exit 1
fi

# Stop containers
docker compose down

# Restore
cp "$BACKUP_DIR/.env" .
cp -r "$BACKUP_DIR/config" .

# Start containers
docker compose up -d

echo "Restored from: $BACKUP_DIR"
```

---

**For more help:** See [troubleshooting guide](troubleshooting.md) or [setup guide](setup-guide.md)

# Troubleshooting Guide

This guide covers common issues and their solutions.

## Quick Diagnostics

Run this first to check overall health:

```bash
./scripts/health-check.sh
./scripts/test-vpn.sh
docker compose logs
```

## Common Issues

### 1. Gluetun Won't Start

**Symptoms:**
- Gluetun container exits immediately
- "Error starting container" message
- Container in restart loop

**Solutions:**

**A. Missing /dev/net/tun**

```bash
# Check if device exists
ls -la /dev/net/tun

# If missing, create it:
sudo mkdir -p /dev/net
sudo mknod /dev/net/tun c 10 200
sudo chmod 666 /dev/net/tun
```

**B. Permission Issues**

```bash
# Give Docker permission to NET_ADMIN capability
# Usually already granted, but check Docker settings
docker info | grep -i security
```

**C. Invalid VPN Credentials**

```bash
# Check your .env file
cat .env | grep -E "VPN_PROVIDER|VPN_TYPE|WIREGUARD|OPENVPN"

# Verify credentials are correct (no extra spaces)
```

**D. Port Conflict**

```bash
# Check if ports 8080 or 8000 are already in use
lsof -i :8080
lsof -i :8000

# Change ports in .env if needed
QBITTORRENT_PORT=127.0.0.1:9090:8080
GLUETUN_CONTROL_PORT=127.0.0.1:9000:8000
```

### 2. VPN Won't Connect

**Symptoms:**
- Gluetun starts but shows connection errors
- "Authentication failed" messages
- Timeout errors

**Solutions:**

**A. Wrong Credentials**

```bash
# For WireGuard - verify keys are correct
grep WIREGUARD_PRIVATE_KEY .env
# Should be 44 characters ending with =

# For OpenVPN - check username/password
grep OPENVPN .env
```

**B. Server Not Available**

```bash
# Try different server location
# In .env:
SERVER_COUNTRIES=US  # Change to different country

# Or leave empty for automatic selection
SERVER_COUNTRIES=
```

**C. Firewall Blocking**

```bash
# Check if your firewall blocks VPN ports
# WireGuard usually uses UDP 51820
# OpenVPN usually uses UDP 1194 or TCP 443

# Test connectivity
ping -c 3 your.vpn.server.com
```

**D. Provider Issues**

```bash
# Check provider's status page
# Try their official app to verify service is working
# Contact provider support if their service is down
```

### 3. Can't Access qBittorrent WebUI

**Symptoms:**
- http://localhost:8080 doesn't load
- Connection refused
- Page timeout

**Solutions:**

**A. Wait for Startup**

```bash
# Services need time to initialize (30-60 seconds)
docker compose ps  # Check if containers are running

# Watch logs
docker compose logs -f qbittorrent
# Wait for "Web UI is accessible" message
```

**B. Check Port Binding**

```bash
# Verify ports are exposed correctly
docker compose ps
# Should show: 127.0.0.1:8080->8080/tcp

# If not visible, check .env
grep QBITTORRENT_PORT .env
```

**C. Gluetun Not Healthy**

```bash
# qBittorrent waits for Gluetun health check
docker compose ps
# Gluetun should show "(healthy)"

# If unhealthy, check Gluetun logs
docker compose logs gluetun
```

**D. Wrong Port Configuration**

```bash
# Try accessing with explicit IP
http://127.0.0.1:8080

# Check Docker port mapping
docker port qbittorrent
# Note: Port is exposed through Gluetun
docker port gluetun
```

### 4. IP Not Changing / VPN Not Working

**Symptoms:**
- Public IP same as real IP
- DNS leaks detected
- Traffic not going through VPN

**Solutions:**

**A. Verify VPN Connection**

```bash
./scripts/test-vpn.sh

# Should show different IP than your real IP
# If same, check Gluetun logs:
docker compose logs gluetun | grep -i "connected\|error"
```

**B. Check Kill Switch**

```bash
# Verify qBittorrent uses Gluetun network
docker inspect qbittorrent | grep -i network
# Should show network_mode: "container:gluetun"
```

**C. DNS Configuration**

```bash
# Verify DNS over TLS is enabled
grep DOT .env
# Should be: DOT=on

# Check DNS in use
docker exec gluetun cat /etc/resolv.conf
# Should show 127.0.0.1
```

### 5. Slow Download Speeds

**Symptoms:**
- Downloads slower than expected
- High latency
- Frequent stalls

**Solutions:**

**A. Choose Nearby Server**

```bash
# In .env, select geographically close server
SERVER_COUNTRIES=US  # If you're in USA

# Try automatic selection
SERVER_COUNTRIES=
```

**B. Switch to WireGuard**

```bash
# If using OpenVPN, switch to WireGuard
# WireGuard is typically 2-3x faster

# In .env:
VPN_TYPE=wireguard
# Add WireGuard credentials
```

**C. Check Server Load**

```bash
# Try different server from same provider
# Some servers may be overloaded

# For Mullvad, check: mullvad.net/servers
```

**D. Port Forwarding**

```bash
# Enable if supported by provider (PIA, ProtonVPN)
VPN_PORT_FORWARDING=on

# Get forwarded port
curl http://localhost:8000/v1/openvpn/portforwarded

# Configure in qBittorrent WebUI
# Tools → Options → Connection → Listening Port
```

### 6. Permission / File Access Errors

**Symptoms:**
- Can't write to downloads folder
- "Permission denied" errors
- Config files not writable

**Solutions:**

**A. Fix PUID/PGID**

```bash
# Get your user/group ID
id -u  # Your UID
id -g  # Your GID

# Update .env
PUID=1000  # Use your UID
PGID=1000  # Use your GID

# Restart containers
docker compose down
docker compose up -d
```

**B. Fix Directory Permissions**

```bash
# Set correct ownership
sudo chown -R $USER:$USER data/
sudo chown -R $USER:$USER config/

# Set permissions
chmod -R 755 data/
chmod -R 755 config/
```

**C. SELinux Issues (Linux)**

```bash
# If on SELinux-enabled system
sudo chcon -Rt svirt_sandbox_file_t data/
sudo chcon -Rt svirt_sandbox_file_t config/
```

### 7. Container Keeps Restarting

**Symptoms:**
- Container shows "Restarting"
- Logs show repeated startup attempts
- System becomes unstable

**Solutions:**

**A. Check Logs**

```bash
docker compose logs --tail=100 gluetun
docker compose logs --tail=100 qbittorrent
```

**B. Remove Restart Policy Temporarily**

```bash
# Stop containers
docker compose down

# Start without restart policy (for debugging)
docker compose up

# Watch for errors
# Press Ctrl+C when done
```

**C. Clear Corrupted Config**

```bash
# Backup current config
mv config config.backup

# Recreate directories
mkdir -p config/{gluetun,qbittorrent,vpn/{wireguard,openvpn}}

# Restart
docker compose up -d
```

### 8. DNS Resolution Failures

**Symptoms:**
- Can't resolve domain names
- "Name or service not known" errors
- Only IP addresses work

**Solutions:**

**A. Verify DoT Configuration**

```bash
# Check .env
grep DOT .env
# Should have: DOT=on

# Check DNS provider
grep DOT_PROVIDERS .env
# Default: cloudflare
```

**B. Try Different DNS Provider**

```bash
# In .env, try different provider
DOT_PROVIDERS=quad9
# or
DOT_PROVIDERS=google
```

**C. Disable DoT Temporarily (not recommended)**

```bash
# Only for troubleshooting
DOT=off

# Restart
docker compose restart gluetun
```

### 9. Port Forwarding Not Working

**Symptoms:**
- Can't get forwarded port
- curl returns empty/0
- Poor torrent connectivity

**Solutions:**

**A. Verify Provider Support**

```bash
# Only these providers support port forwarding:
# - Private Internet Access (PIA)
# - ProtonVPN
# - AirVPN
# - Perfect Privacy

# Check if enabled
grep VPN_PORT_FORWARDING .env
```

**B. Check Port Status**

```bash
# Query Gluetun API
curl http://localhost:8000/v1/openvpn/portforwarded

# Should return a port number (not 0)
```

**C. Enable Port Forwarding**

```bash
# In .env
VPN_PORT_FORWARDING=on
VPN_PORT_FORWARDING_PROVIDER=private internet access

# Restart
docker compose restart gluetun
```

### 10. macOS Specific Issues

**A. Docker Desktop Not Running**

```bash
# Start Docker Desktop from Applications
# Wait for whale icon in menu bar

# Verify
docker info
```

**B. File Sharing Permissions**

```bash
# Docker Desktop → Settings → Resources → File Sharing
# Add project directory if not listed
```

**C. Port Already in Use**

```bash
# Check what's using port 8080
lsof -i :8080

# Kill the process or use different port in .env
```

## Diagnostic Commands

### Check Container Status

```bash
# List running containers
docker compose ps

# Detailed container info
docker inspect gluetun
docker inspect qbittorrent
```

### View Logs

```bash
# All logs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# Last 100 lines
docker compose logs --tail=100

# Specific container
docker compose logs gluetun
docker compose logs qbittorrent

# With timestamps
docker compose logs -t
```

### Test VPN Connection

```bash
# Automated test
./scripts/test-vpn.sh

# Manual IP check
curl http://localhost:8000/v1/publicip/ip

# DNS check
docker exec gluetun cat /etc/resolv.conf

# Port forwarding check
curl http://localhost:8000/v1/openvpn/portforwarded
```

### Resource Usage

```bash
# Check resource usage
docker stats

# Disk usage
docker system df

# Container resource limits
docker compose top
```

### Network Debugging

```bash
# Test connectivity from inside Gluetun
docker exec gluetun ping -c 3 cloudflare.com

# Check routes
docker exec gluetun ip route

# Check firewall rules
docker exec gluetun iptables -L -n
```

## Getting Additional Help

### Information to Provide

When asking for help, include:

1. **Operating System:**
   ```bash
   uname -a  # Linux/macOS
   # or: Windows version
   ```

2. **Docker Version:**
   ```bash
   docker version
   docker compose version
   ```

3. **Configuration (sanitized):**
   ```bash
   cat .env | sed 's/KEY=.*/KEY=REDACTED/' | sed 's/PASSWORD=.*/PASSWORD=REDACTED/'
   ```

4. **Logs:**
   ```bash
   docker compose logs --tail=100 > logs.txt
   ```

5. **Test Results:**
   ```bash
   ./scripts/test-vpn.sh > test-results.txt
   ./scripts/health-check.sh >> test-results.txt
   ```

### Where to Get Help

1. **Documentation:**
   - [Setup Guide](setup-guide.md)
   - [Advanced Configuration](advanced-configuration.md)
   - [VPN Provider Guides](vpn-providers/)

2. **Upstream Projects:**
   - [Gluetun Issues](https://github.com/qdm12/gluetun/issues)
   - [Gluetun Wiki](https://github.com/qdm12/gluetun-wiki)
   - [qBittorrent Forum](https://qbforums.shiki.hu/)

3. **Community:**
   - GitHub Issues (this project)
   - Reddit: r/VPN, r/selfhosted
   - Docker Community Forums

## Preventive Maintenance

### Regular Tasks

**Weekly:**
```bash
# Check health
./scripts/health-check.sh

# View logs for errors
docker compose logs | grep -i error
```

**Monthly:**
```bash
# Update images
docker compose pull
docker compose up -d

# Clean up
docker system prune -f
```

**Quarterly:**
```bash
# Rotate VPN keys (if possible)
# Backup configuration
tar -czf backup-$(date +%Y%m%d).tar.gz config/ .env
```

---

**Still having issues?** Create a GitHub issue with:
- Detailed description
- Steps to reproduce
- Sanitized configuration
- Relevant logs
- Output from diagnostic commands

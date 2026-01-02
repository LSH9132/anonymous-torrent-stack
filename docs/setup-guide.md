# Setup Guide

This guide will walk you through setting up the Anonymous Torrent Stack step by step.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [VPN Provider Configuration](#vpn-provider-configuration)
- [Starting the Stack](#starting-the-stack)
- [Accessing qBittorrent](#accessing-qbittorrent)
- [Verification](#verification)
- [Next Steps](#next-steps)

## Prerequisites

### Required

1. **Docker** (version 20.10 or higher)
   - macOS: [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
   - Windows: [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
   - Linux: [Docker Engine](https://docs.docker.com/engine/install/)

2. **Docker Compose** (usually included with Docker Desktop)
   - Check version: `docker compose version`
   - Minimum version: 1.29.0

3. **Active VPN Subscription**
   - Recommended: Mullvad, ProtonVPN, NordVPN, or PIA
   - See [supported providers](vpn-providers/supported-providers.md)

### Recommended

- Basic command line knowledge
- Text editor (nano, vim, or VS Code)
- 10 GB free disk space for downloads

## Installation

### Step 1: Get the Project

Clone the repository or download the source code:

```bash
git clone <repository-url>
cd anonymous-torrent-stack
```

Or download and extract the ZIP file.

### Step 2: Run Setup Script

The setup script will guide you through the initial configuration:

```bash
./scripts/setup.sh
```

This script will:
- Verify Docker and Docker Compose are installed
- Create a `.env` file from the template
- Set your user/group ID automatically
- Detect your timezone
- Prompt for VPN provider and protocol selection
- Configure port settings

**Output Example:**
```
========================================
Anonymous Torrent Stack - Setup
========================================

[INFO] Checking prerequisites...
[SUCCESS] Docker is installed
[SUCCESS] Docker Compose is installed
[SUCCESS] Docker daemon is running
[SUCCESS] Created .env file from template
[SUCCESS] Set PUID=1000 and PGID=1000
[SUCCESS] Set timezone to America/New_York

========================================
VPN Configuration
========================================

Enter your VPN provider name (or 'custom' for custom config): mullvad
Select VPN protocol (wireguard/openvpn) [wireguard]: wireguard

========================================
Port Configuration
========================================

qBittorrent WebUI port configuration:
  1. localhost:8080 (recommended - local access only)
  2. 8080:8080 (network accessible - requires authentication)

Select option [1]: 1

[SUCCESS] Setup complete!
```

### Step 3: Configure VPN Credentials

Edit the `.env` file to add your VPN credentials:

```bash
nano .env
# or
vim .env
# or open in your favorite text editor
```

Choose your scenario:

#### Scenario A: Mullvad with WireGuard (Recommended)

1. Log in to [Mullvad](https://mullvad.net/)
2. Go to "WireGuard configuration"
3. Generate a WireGuard key if you haven't already
4. Copy the configuration details

Update `.env`:
```bash
VPN_PROVIDER=mullvad
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=your_private_key_from_mullvad
WIREGUARD_ADDRESSES=your_addresses_from_mullvad
SERVER_COUNTRIES=SE  # Optional: Sweden, or any country code
```

#### Scenario B: Custom WireGuard Provider

1. Download your WireGuard config from your VPN provider
2. Copy it to `config/vpn/wireguard/wg0.conf`
3. Update `.env`:

```bash
VPN_PROVIDER=custom
VPN_TYPE=wireguard
```

See [Custom WireGuard Guide](vpn-providers/custom-wireguard.md)

#### Scenario C: OpenVPN Provider

1. Download your OpenVPN config (.ovpn file) from your VPN provider
2. Copy it to `config/vpn/openvpn/custom.conf`
3. Update `.env`:

```bash
VPN_PROVIDER=custom
VPN_TYPE=openvpn
OPENVPN_CUSTOM_CONFIG=/gluetun/custom/custom.conf
```

Or for built-in providers:
```bash
VPN_PROVIDER=nordvpn  # or protonvpn, etc.
VPN_TYPE=openvpn
OPENVPN_USER=your_username
OPENVPN_PASSWORD=your_password
SERVER_COUNTRIES=US
```

See provider-specific guides in [vpn-providers/](vpn-providers/)

## VPN Provider Configuration

### Built-in Providers

For providers supported by Gluetun (60+), you only need to configure `.env`:

**Example: NordVPN with OpenVPN**
```bash
VPN_PROVIDER=nordvpn
VPN_TYPE=openvpn
OPENVPN_USER=your_nordvpn_email
OPENVPN_PASSWORD=your_nordvpn_password
SERVER_COUNTRIES=US,CA  # USA and Canada
```

**Example: Private Internet Access with WireGuard**
```bash
VPN_PROVIDER=private internet access
VPN_TYPE=wireguard
WIREGUARD_PRIVATE_KEY=your_pia_private_key
WIREGUARD_ADDRESSES=your_pia_addresses
VPN_PORT_FORWARDING=on  # PIA supports port forwarding
```

### Custom Providers

If your VPN provider isn't built-in, use custom configuration:

1. Get your VPN config file (WireGuard or OpenVPN)
2. Place it in the appropriate directory:
   - WireGuard: `config/vpn/wireguard/wg0.conf`
   - OpenVPN: `config/vpn/openvpn/custom.conf`
3. Set `VPN_PROVIDER=custom` in `.env`

## Starting the Stack

### First Time Start

1. **Start the containers in detached mode:**

```bash
docker compose up -d
```

2. **Watch the logs to monitor startup:**

```bash
docker compose logs -f
```

You should see:
- Gluetun connecting to VPN server
- qBittorrent waiting for Gluetun to be healthy
- qBittorrent starting after VPN connection is established

**Press Ctrl+C to stop viewing logs** (containers will keep running)

### Expected Startup Sequence

1. **Gluetun starts** (10-30 seconds)
   ```
   gluetun | INFO [dns over tls] using plaintext DNS at address 1.1.1.1:53
   gluetun | INFO [vpn] starting
   gluetun | INFO [vpn] connected
   gluetun | INFO [healthcheck] program has been running for 31s
   ```

2. **Gluetun becomes healthy** (after successful VPN connection)
   ```
   gluetun | INFO [healthcheck] healthy!
   ```

3. **qBittorrent starts** (waits for Gluetun health check)
   ```
   qbittorrent | **************************************
   qbittorrent | Web UI is accessible at http://localhost:8080
   qbittorrent | **************************************
   ```

### Verifying Startup

Check container status:
```bash
docker compose ps
```

Expected output:
```
NAME          STATUS                    PORTS
gluetun       Up 2 minutes (healthy)    127.0.0.1:8000->8000/tcp, 127.0.0.1:8080->8080/tcp
qbittorrent   Up 1 minute
```

## Accessing qBittorrent

### Open the Web UI

Navigate to: [http://localhost:8080](http://localhost:8080)

### Default Credentials

- **Username:** `admin`
- **Password:** `adminadmin`

### First Login Steps

1. **Log in with default credentials**

2. **Change the password immediately:**
   - Go to Tools → Options → Web UI
   - Authentication section
   - Enter new username and password
   - Click "Save"

3. **Optional: Configure additional settings:**
   - Downloads → Save path: `/downloads` (already configured)
   - Connection → Listening Port: Use forwarded port if available
   - BitTorrent → Privacy → Enable anonymous mode
   - BitTorrent → Encryption: Require encryption

## Verification

### Test VPN Connection

Run the test script:

```bash
./scripts/test-vpn.sh
```

This will check:
- ✓ VPN connection status
- ✓ Public IP (should be different from your real IP)
- ✓ DNS leak protection
- ✓ Kill switch functionality
- ✓ qBittorrent WebUI accessibility

**Expected Output:**
```
========================================
VPN Connection Test
========================================

[✓] Containers are running
[✓] VPN IP Address: 185.65.134.66
[✓] Location: Stockholm, Sweden
[✓] VPN is working! Your IP is hidden.
[✓] DNS is using Gluetun's DoT (DNS over TLS)
[✓] VPN connection is active
[✓] qBittorrent WebUI is accessible at http://localhost:8080
[✓] All tests completed!
```

### Manual Verification

1. **Check your public IP through qBittorrent:**
   - In qBittorrent, add a test torrent (e.g., Ubuntu ISO)
   - Go to a site like [iknowwhatyoudownload.com](https://iknowwhatyoudownload.com/)
   - Verify it shows your VPN IP, not your real IP

2. **Test the kill switch:**
   ```bash
   # Stop Gluetun
   docker stop gluetun

   # Try to access qBittorrent WebUI - should fail
   curl http://localhost:8080
   # Expected: Connection refused or timeout

   # Restart Gluetun
   docker start gluetun

   # Wait 30 seconds, then access should work again
   ```

3. **DNS leak test:**
   ```bash
   # Check DNS servers in use
   docker exec gluetun cat /etc/resolv.conf
   # Should show 127.0.0.1 (Gluetun's DoT)
   ```

## Next Steps

### Configure Port Forwarding (Optional)

If your VPN provider supports port forwarding (PIA, ProtonVPN):

1. Enable in `.env`:
   ```bash
   VPN_PORT_FORWARDING=on
   ```

2. Restart containers:
   ```bash
   docker compose down
   docker compose up -d
   ```

3. Check forwarded port:
   ```bash
   curl http://localhost:8000/v1/openvpn/portforwarded
   ```

4. Configure in qBittorrent:
   - Tools → Options → Connection
   - Listening Port: Use the forwarded port number
   - Uncheck "Use UPnP/NAT-PMP"

### Network Access (Optional)

To access qBittorrent from other devices on your network:

1. Update `.env`:
   ```bash
   QBITTORRENT_PORT=8080:8080
   ```

2. Restart:
   ```bash
   docker compose down
   docker compose up -d
   ```

3. Access from other devices:
   ```
   http://YOUR_COMPUTER_IP:8080
   ```

**Security Note:** Ensure you've changed the default password!

### Set Up Health Monitoring

Monitor your stack's health:

```bash
# One-time check
./scripts/health-check.sh

# Continuous monitoring (every 30 seconds)
watch -n 30 ./scripts/health-check.sh
```

### Configure Download Categories

In qBittorrent:
1. Tools → Options → Downloads
2. "Append the label of the torrent to the save path" → Enable
3. Create categories for better organization

### Add RSS Feeds (Optional)

1. View → RSS Reader → Enable
2. Add your favorite torrent site's RSS feed
3. Set up automatic downloading rules

## Common Issues

### Gluetun Won't Start

**Symptom:** Gluetun container exits or restarts repeatedly

**Solution:**
1. Check logs: `docker compose logs gluetun`
2. Verify credentials in `.env`
3. Try different server: `SERVER_COUNTRIES=US`
4. Check [troubleshooting guide](troubleshooting.md)

### qBittorrent Shows "Offline"

**Symptom:** qBittorrent WebUI not accessible

**Solution:**
1. Wait 60 seconds after startup
2. Check if Gluetun is healthy: `docker compose ps`
3. Verify port binding: `docker compose ps | grep 8080`
4. Check qBittorrent logs: `docker compose logs qbittorrent`

### VPN Connected But Same IP

**Symptom:** Your IP hasn't changed

**Solution:**
1. Run: `./scripts/test-vpn.sh`
2. Check Gluetun logs for connection errors
3. Verify VPN credentials are correct
4. Try different VPN server location

### Permission Errors

**Symptom:** Can't write to downloads folder

**Solution:**
1. Check PUID/PGID in `.env` match your user:
   ```bash
   id -u  # Get your UID
   id -g  # Get your GID
   ```
2. Update `.env` with correct values
3. Restart: `docker compose down && docker compose up -d`

## Additional Resources

- [VPN Provider Guides](vpn-providers/) - Provider-specific setup
- [Troubleshooting](troubleshooting.md) - Common problems and solutions
- [Advanced Configuration](advanced-configuration.md) - Power user features
- [Gluetun Wiki](https://github.com/qdm12/gluetun-wiki) - Official Gluetun documentation

## Support

If you encounter issues:

1. Check the [troubleshooting guide](troubleshooting.md)
2. Review container logs: `docker compose logs`
3. Run the test script: `./scripts/test-vpn.sh`
4. Search existing GitHub issues
5. Create a new GitHub issue with:
   - Your `.env` configuration (remove sensitive data!)
   - Container logs
   - Output from test script

---

**Congratulations!** You now have a fully functional anonymous torrent stack with VPN protection and kill switch. Happy (legal) torrenting!

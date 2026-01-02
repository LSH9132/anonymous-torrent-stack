# Anonymous Torrent Stack

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/v/release/LSH9132/anonymous-torrent-stack)](https://github.com/LSH9132/anonymous-torrent-stack/releases)
[![CI](https://github.com/LSH9132/anonymous-torrent-stack/workflows/CI/badge.svg)](https://github.com/LSH9132/anonymous-torrent-stack/actions/workflows/ci.yml)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![WireGuard](https://img.shields.io/badge/WireGuard-88171A?logo=wireguard&logoColor=white)](https://www.wireguard.com/)

[![GitHub stars](https://img.shields.io/github/stars/LSH9132/anonymous-torrent-stack?style=social)](https://github.com/LSH9132/anonymous-torrent-stack/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/LSH9132/anonymous-torrent-stack?style=social)](https://github.com/LSH9132/anonymous-torrent-stack/network/members)

**English** | [한국어](README.ko.md)

</div>

---

A Docker-based solution for anonymous torrenting using VPN (WireGuard/OpenVPN) with qBittorrent. Features automatic kill switch, DNS leak protection, and support for 60+ VPN providers.

## Features

### Security & Privacy
- **Triple-Layer Kill Switch**: Network isolation + firewall rules + DNS protection
- **DNS Leak Protection**: Encrypted DNS over TLS (DoT) prevents ISP tracking
- **No IP Leaks**: All torrent traffic routes exclusively through VPN
- **Multi-Provider Support**: Works with Mullvad, ProtonVPN, NordVPN, PIA, and 60+ more
- **Protocol Flexibility**: WireGuard (recommended) or OpenVPN support

### Reliability
- **Auto-Reconnect**: Automatic VPN reconnection with escalating retry timeouts
- **Health Monitoring**: Built-in health checks for VPN and torrent client
- **Container Isolation**: Docker-level network security prevents leaks
- **Graceful Degradation**: qBittorrent stops automatically if VPN fails

### Ease of Use
- **5-Minute Setup**: Automated setup script with interactive configuration
- **Simple Configuration**: Environment variable based setup
- **Testing Scripts**: Built-in VPN connection and leak testing tools
- **Comprehensive Documentation**: Step-by-step guides for every VPN provider

## Architecture

```
┌─────────────────────────────────────────┐
│           Docker Host Network            │
│  ┌────────────────────────────────────┐ │
│  │      Gluetun (VPN Container)       │ │
│  │  ┌──────────────────────────────┐  │ │
│  │  │  VPN Tunnel (WireGuard/OVPN) │  │ │
│  │  │  ┌────────────────────────┐  │  │ │
│  │  │  │   qBittorrent Client   │  │  │ │
│  │  │  │  (network_mode: gluetun)│ │  │ │
│  │  │  └────────────────────────┘  │  │ │
│  │  │   Kill Switch: Triple-Layer  │  │ │
│  │  └──────────────────────────────┘  │ │
│  │  Ports: 8080 (WebUI), 8000 (API)  │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**How it works:**
1. Gluetun establishes a VPN connection with your provider
2. qBittorrent uses `network_mode: service:gluetun` to share Gluetun's network
3. All qBittorrent traffic must go through Gluetun's VPN tunnel
4. If VPN disconnects, qBittorrent loses all network access (kill switch)

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Active VPN subscription (Mullvad, ProtonVPN, NordVPN, etc.)
- 5 minutes of your time

### Installation

1. **Clone or download this repository**
   ```bash
   git clone <repository-url>
   cd anonymous-torrent-stack
   ```

2. **Run the setup script**
   ```bash
   ./scripts/setup.sh
   ```
   This creates your `.env` file and configures basic settings.

3. **Configure your VPN credentials**

   Edit the `.env` file and add your VPN details:

   **Option A: Mullvad with WireGuard (Recommended)**
   ```bash
   VPN_PROVIDER=mullvad
   VPN_TYPE=wireguard
   WIREGUARD_PRIVATE_KEY=your_private_key_here
   WIREGUARD_ADDRESSES=your_addresses_here
   SERVER_COUNTRIES=SE
   ```

   **Option B: Custom WireGuard Provider**
   ```bash
   VPN_PROVIDER=custom
   VPN_TYPE=wireguard
   # Place your wg0.conf in config/vpn/wireguard/
   ```

   **Option C: Custom OpenVPN Provider**
   ```bash
   VPN_PROVIDER=custom
   VPN_TYPE=openvpn
   OPENVPN_CUSTOM_CONFIG=/gluetun/custom/your-config.conf
   # Place your .ovpn file in config/vpn/openvpn/
   ```

   See [docs/vpn-providers/](docs/vpn-providers/) for provider-specific guides.

4. **Start the stack**
   ```bash
   docker compose up -d
   ```

5. **Test your connection**
   ```bash
   ./scripts/test-vpn.sh
   ```

6. **Access qBittorrent**

   Open [http://localhost:8080](http://localhost:8080)

   Default credentials:
   - Username: `admin`
   - Password: `adminadmin`

   **⚠️ Change these immediately after first login!**

## VPN Provider Setup

### Supported Providers (60+)

This stack supports 60+ VPN providers out of the box through Gluetun:

**Popular Providers:**
- Mullvad (recommended for privacy)
- ProtonVPN
- NordVPN
- Private Internet Access (PIA)
- ExpressVPN
- Surfshark
- Windscribe
- IPVanish
- And many more...

See [docs/vpn-providers/supported-providers.md](docs/vpn-providers/supported-providers.md) for the complete list.

### Quick Setup Guides

- [Mullvad + WireGuard](docs/vpn-providers/mullvad-wireguard.md) ⭐ Recommended
- [Mullvad + OpenVPN](docs/vpn-providers/mullvad-openvpn.md)
- [Custom WireGuard](docs/vpn-providers/custom-wireguard.md)
- [Custom OpenVPN](docs/vpn-providers/custom-openvpn.md)

## Configuration

### Port Configuration

**Localhost Only (Default - Recommended)**
```bash
QBITTORRENT_PORT=127.0.0.1:8080
```
WebUI only accessible from your local machine.

**Network Accessible**
```bash
QBITTORRENT_PORT=8080:8080
```
WebUI accessible from other devices on your network. Ensure you set a strong password!

### Advanced Features

#### Port Forwarding

Some VPN providers (PIA, ProtonVPN) support port forwarding for better peer connectivity:

```bash
VPN_PORT_FORWARDING=on
```

The forwarded port will automatically be detected and can be configured in qBittorrent for improved download/upload speeds.

#### Custom DNS Providers

```bash
DOT_PROVIDERS=cloudflare  # Default
# Or: quad9, google, quadrant
```

#### Firewall Configuration

Allow access to local network (for WebUI):
```bash
FIREWALL_OUTBOUND_SUBNETS=192.168.1.0/24,172.20.0.0/16
```

## Usage

### Starting the Stack
```bash
docker compose up -d
```

### Stopping the Stack
```bash
docker compose down
```

### Viewing Logs
```bash
# All logs
docker compose logs -f

# Gluetun only
docker compose logs -f gluetun

# qBittorrent only
docker compose logs -f qbittorrent
```

### Health Check
```bash
./scripts/health-check.sh

# Continuous monitoring (every 30 seconds)
watch -n 30 ./scripts/health-check.sh
```

### Testing VPN Connection
```bash
./scripts/test-vpn.sh
```

This script checks:
- VPN connection status
- Public IP (should be different from your real IP)
- DNS leak protection
- Kill switch status
- qBittorrent WebUI accessibility

## Security Features

### Kill Switch (Triple-Layer Protection)

1. **Network Isolation (Primary)**
   - `network_mode: service:gluetun` ensures qBittorrent can only communicate through Gluetun
   - If Gluetun stops or crashes, qBittorrent loses all network access
   - Docker-level enforcement (most reliable method)

2. **Firewall Rules (Secondary)**
   - Gluetun's built-in iptables rules block all non-VPN traffic
   - Configurable to allow local network access for WebUI
   - Blocks all traffic when VPN tunnel is down

3. **DNS Leak Prevention (Tertiary)**
   - DNS over TLS (DoT) encrypts all DNS queries
   - All DNS traffic goes through Cloudflare/Quad9
   - DNS disabled until VPN tunnel is established
   - No plain DNS queries to your ISP

### Verification

To verify the kill switch is working:

1. Start the stack and verify qBittorrent WebUI is accessible
2. Stop Gluetun: `docker stop gluetun`
3. Try to access qBittorrent WebUI - it should fail
4. Start Gluetun: `docker start gluetun`
5. WebUI should work again after ~30 seconds

## Troubleshooting

### VPN Won't Connect

1. Check your credentials in `.env`
2. View Gluetun logs: `docker compose logs gluetun`
3. Try a different server: `SERVER_COUNTRIES=US` (change country code)
4. See [docs/troubleshooting.md](docs/troubleshooting.md)

### Can't Access WebUI

1. Wait 30-60 seconds after starting (services need time to initialize)
2. Check if containers are running: `docker ps`
3. Verify Gluetun is healthy: `docker compose ps`
4. Check port binding: `QBITTORRENT_PORT=127.0.0.1:8080` in `.env`

### IP Not Changing

1. Run `./scripts/test-vpn.sh` to verify VPN connection
2. Check Gluetun logs for connection errors
3. Verify your VPN credentials are correct
4. Try a different VPN server/location

For more issues, see [docs/troubleshooting.md](docs/troubleshooting.md)

## Project Structure

```
anonymous-torrent-stack/
├── docker-compose.yml          # Main Docker Compose configuration
├── .env.example                # Environment variable template
├── .gitignore                  # Git ignore rules
├── README.md                   # This file
├── LICENSE                     # MIT License
├── config/
│   ├── gluetun/               # Gluetun configuration (auto-generated)
│   ├── qbittorrent/           # qBittorrent configuration (auto-generated)
│   └── vpn/
│       ├── wireguard/         # Custom WireGuard configs
│       │   └── wg0.conf.example
│       └── openvpn/           # Custom OpenVPN configs
│           └── custom.conf.example
├── data/
│   ├── qbittorrent/           # qBittorrent app data
│   └── downloads/             # Downloaded files
├── scripts/
│   ├── setup.sh               # Interactive setup script
│   ├── test-vpn.sh            # VPN connection tester
│   └── health-check.sh        # Health monitoring script
└── docs/
    ├── setup-guide.md         # Detailed setup instructions
    ├── troubleshooting.md     # Common issues and solutions
    ├── advanced-configuration.md  # Advanced topics
    └── vpn-providers/         # Provider-specific guides
        ├── mullvad-wireguard.md
        ├── mullvad-openvpn.md
        ├── custom-wireguard.md
        ├── custom-openvpn.md
        └── supported-providers.md
```

## Documentation

- [Setup Guide](docs/setup-guide.md) - Detailed setup instructions
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Advanced Configuration](docs/advanced-configuration.md) - Port forwarding, custom DNS, performance tuning
- [VPN Provider Guides](docs/vpn-providers/) - Provider-specific instructions

## Extending the Stack

This architecture makes it easy to add additional services that also use the VPN:

```yaml
services:
  # ... existing gluetun and qbittorrent services ...

  jackett:
    image: lscr.io/linuxserver/jackett:latest
    container_name: jackett
    network_mode: "service:gluetun"  # Routes through VPN
    depends_on:
      gluetun:
        condition: service_healthy
    # ... other configuration ...
```

Popular additions:
- **Jackett/Prowlarr**: Torrent indexer aggregation
- **Radarr/Sonarr**: Automated movie/TV show management
- **Grafana/Prometheus**: Monitoring and dashboards
- **Tautulli**: Plex media server statistics

## FAQ

**Q: Which VPN provider do you recommend?**
A: Mullvad is excellent for privacy and supports both WireGuard and OpenVPN. ProtonVPN is also a great choice with a free tier option.

**Q: Is WireGuard better than OpenVPN?**
A: Yes, WireGuard is generally recommended because it's faster, more secure, uses modern cryptography, and has a simpler configuration.

**Q: Can I use this with a free VPN?**
A: Technically yes, but free VPNs often have bandwidth limits, poor performance, and questionable privacy practices. A paid VPN is strongly recommended.

**Q: Will this slow down my downloads?**
A: There's typically a 10-30% speed reduction due to VPN encryption overhead. WireGuard is faster than OpenVPN. Your actual speed depends on your VPN provider's server quality.

**Q: Is this legal?**
A: Using a VPN and torrent client is legal in most countries. However, downloading copyrighted content without permission is illegal in many jurisdictions. This tool is for legal torrenting only.

**Q: Can I access the WebUI from my phone/tablet?**
A: Yes! Set `QBITTORRENT_PORT=8080:8080` in `.env` to enable network access. Make sure to use a strong password.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Disclaimer

This project is for educational purposes and legal use only. The developers are not responsible for any misuse of this software. Always respect copyright laws and your VPN provider's terms of service.

## Acknowledgments

- [Gluetun](https://github.com/qdm12/gluetun) - Excellent VPN client container by @qdm12
- [qBittorrent](https://www.qbittorrent.org/) - Free and open-source torrent client
- [LinuxServer.io](https://www.linuxserver.io/) - High-quality Docker images

---

**⭐ If you find this project useful, please consider starring it on GitHub!**

For questions or issues, see [docs/troubleshooting.md](docs/troubleshooting.md) or open an issue on GitHub.
